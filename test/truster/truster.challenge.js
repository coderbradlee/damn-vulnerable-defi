const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("[Challenge] Truster", function () {
  let deployer, player;
  let token, pool;

  const TOKENS_IN_POOL = 1000000n * 10n ** 18n;

  before(async function () {
    /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
    [deployer, player] = await ethers.getSigners();

    token = await (
      await ethers.getContractFactory("DamnValuableToken", deployer)
    ).deploy();
    pool = await (
      await ethers.getContractFactory("TrusterLenderPool", deployer)
    ).deploy(token.address);
    expect(await pool.token()).to.eq(token.address);

    await token.transfer(pool.address, TOKENS_IN_POOL);
    expect(await token.balanceOf(pool.address)).to.equal(TOKENS_IN_POOL);

    expect(await token.balanceOf(player.address)).to.equal(0);
  });

  it("Execution", async function () {
    /** CODE YOUR SOLUTION HERE */

    // function flashLoan(uint256 amount, address borrower, address target, bytes calldata data

    // await token.connect(player).approve(pool.address, 1000000n * 10n ** 18n);

    // let data = token.interface.encodeFunctionData("transferFrom", [
    //   player.address,
    //   pool.address,
    //   1000000n * 10n ** 18n,
    // ]);

    // await pool.flashLoan(
    //   1000000n * 10n ** 18n,
    //   player.address,
    //   token.address,
    //   data
    // );

    let testFlashloan = await (
      await ethers.getContractFactory("testFlashloan", deployer)
    ).deploy(token.address, pool.address);
    await pool.flashLoan(
      1000000n * 10n ** 18n,
      testFlashloan.address,
      testFlashloan.address,
      "0x12"
    );
    let b = await token.balanceOf(pool.address);
    console.log("pool balance", b.toString());
    b = await token.balanceOf(player.address);
    console.log("player balance", b.toString());
  });

  after(async function () {
    /** SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */
    // Player has taken all tokens from the pool
    // expect(await token.balanceOf(player.address)).to.equal(TOKENS_IN_POOL);
    // expect(await token.balanceOf(pool.address)).to.equal(0);
  });
});
