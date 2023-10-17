// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract testFlashloan {
    address public token;
    address public pool;

    constructor(address _token, address _pool) {
        token = _token;
        pool = _pool;
    }

    fallback() external payable {
        token.call(
            abi.encodeWithSignature(
                "transfer(address,uint256)",
                pool,
                1000000e18
            )
        );
    }
}
