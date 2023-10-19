const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("[Challenge] Backdoor", function () {
  let deployer, users, player;
  let masterCopy, walletFactory, token, walletRegistry;

  const AMOUNT_TOKENS_DISTRIBUTED = 40n * 10n ** 18n;

  before(async function () {
    /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
    [deployer, alice, bob, charlie, david, player] = await ethers.getSigners();
    users = [alice.address, bob.address, charlie.address, david.address];

    // Deploy Gnosis Safe master copy and factory contracts
    masterCopy = await (
      await ethers.getContractFactory("GnosisSafe", deployer)
    ).deploy();
    walletFactory = await (
      await ethers.getContractFactory("GnosisSafeProxyFactory", deployer)
    ).deploy();
    token = await (
      await ethers.getContractFactory("DamnValuableToken", deployer)
    ).deploy();

    // Deploy the registry
    walletRegistry = await (
      await ethers.getContractFactory("WalletRegistry", deployer)
    ).deploy(masterCopy.address, walletFactory.address, token.address, users);
    expect(await walletRegistry.owner()).to.eq(deployer.address);

    for (let i = 0; i < users.length; i++) {
      // Users are registered as beneficiaries
      expect(await walletRegistry.beneficiaries(users[i])).to.be.true;

      // User cannot add beneficiaries
      await expect(
        walletRegistry
          .connect(await ethers.getSigner(users[i]))
          .addBeneficiary(users[i])
      ).to.be.revertedWithCustomError(walletRegistry, "Unauthorized");
    }

    // Transfer tokens to be distributed to the registry
    await token.transfer(walletRegistry.address, AMOUNT_TOKENS_DISTRIBUTED);
  });

  it("Execution", async function () {
    /** CODE YOUR SOLUTION HERE */
    let testWalletRegistry = await (
      await ethers.getContractFactory("testWalletRegistry", player)
    ).deploy(
      token.address,
      player.address,
      users,
      masterCopy.address,
      walletFactory.address,
      walletRegistry.address
    );

    //    await testFlashloanFreeRider.start();
    // let datas;
    // let signatures;
    // for (let i = 0; i < 1; i++) {
    //   // setup(
    //   // address[] calldata _owners,
    //   // uint256 _threshold,
    //   // address to,
    //   // bytes calldata data,
    //   // address fallbackHandler,
    //   // address paymentToken,
    //   // uint256 payment,
    //   // address payable paymentReceiver
    //   let calldata = testWalletRegistry.interface.encodeFunctionData("setup", [
    //     users,
    //     0,
    //     player.address,
    //     "0x01",
    //     player.address,
    //     player.address,
    //     0,
    //     player.address,
    //   ]);

    //   //   GnosisSafeProxy proxy, address singleton, bytes calldata initializer, uint256)
    //   let data = walletRegistry.interface.encodeFunctionData("proxyCreated", [
    //     testWalletRegistry.address,
    //     masterCopy.address,
    //     calldata,
    //     0,
    //   ]);

    //   //     getTransactionHash(
    //   //     address to,
    //   //     uint256 value,
    //   //     bytes calldata data,
    //   //     Enum.Operation operation,
    //   //     uint256 safeTxGas,
    //   //     uint256 baseGas,
    //   //     uint256 gasPrice,
    //   //     address gasToken,
    //   //     address refundReceiver,
    //   //     uint256 _nonce
    //   // ) public view returns (bytes32)
    //   let hash = walletFactory.getTransactionHash(
    //     walletRegistry.address,
    //     0,
    //     data,
    //     0,
    //     1000000n,
    //     1000000n,
    //     0,
    //     0x0,
    //     player.address,
    //     i
    //   );
    //   console.log("hash", hash.toString());
    //   let signature = await player.signMessage(hash);
    //   datas[i] = data;
    //   signatures[i] = signature;
    //   // function execTransaction(
    //   // address to,
    //   // uint256 value,
    //   // bytes calldata data,
    //   // Enum.Operation operation,
    //   // uint256 safeTxGas,
    //   // uint256 baseGas,
    //   // uint256 gasPrice,
    //   // address gasToken,
    //   // address payable refundReceiver,
    //   // bytes memory signatures
    // //     function createProxyWithCallback(
    // //     address _singleton,
    // //     bytes memory initializer,
    // //     uint256 saltNonce,
    // //     IProxyCreationCallback callback
    // // ) public returns (GnosisSafeProxy proxy)
    // }

    // await testWalletRegistry.connect(player).start();
    // await testWalletRegistry.end();
  });

  after(async function () {
    /** SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */
    // Player must have used a single transaction
    expect(await ethers.provider.getTransactionCount(player.address)).to.eq(1);
    for (let i = 0; i < users.length; i++) {
      let wallet = await walletRegistry.wallets(users[i]);
      // User must have registered a wallet
      expect(wallet).to.not.eq(
        ethers.constants.AddressZero,
        "User did not register a wallet"
      );
      // User is no longer registered as a beneficiary
      expect(await walletRegistry.beneficiaries(users[i])).to.be.false;
    }
    // Player must own all tokens
    // expect(await token.balanceOf(player.address)).to.eq(
    //   AMOUNT_TOKENS_DISTRIBUTED
    // );
  });
});
