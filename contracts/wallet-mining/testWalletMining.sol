// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

contract testWalletMining {
    address token;
    address timelock;
    address climber;
    address player;

    // constructor(
    //     address _token,
    //     address _timelock,
    //     address _climber,
    //     address _player
    // ) {
    //     token = _token;
    //     player = _player;
    //     timelock = _timelock;
    //     climber = _climber;
    // }

    function start() external {
       bytes memory data = abi.encodeWithSelector(0xa9059cbb, address(1), 2);
       
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
