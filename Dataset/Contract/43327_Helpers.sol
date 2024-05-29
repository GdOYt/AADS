contract Helpers is DSMath {
    function getAddressETH() public pure returns (address eth) {
        eth = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    }
    function getAddressWETH() public pure returns (address eth) {
        eth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    }
    function getAddressUSDC() public pure returns (address usdc) {
        usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    }
    function getAddressZRXExchange() public pure returns (address zrxExchange) {
        zrxExchange = 0x080bf510FCbF18b91105470639e9561022937712;
    }
    function getAddressZRXERC20() public pure returns (address zrxerc20) {
        zrxerc20 = 0x95E6F48254609A6ee006F7D493c8e5fB97094ceF;
    }
    function getAddressKyberProxy() public pure returns (address kyberProxy) {
        kyberProxy = 0x818E6FECD516Ecc3849DAf6845e3EC868087B755;
    }
    function getComptrollerAddress() public pure returns (address troller) {
        troller = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;
    }
    function getCompOracleAddress() public pure returns (address troller) {
        troller = 0xe7664229833AE4Abf4E269b8F23a86B657E2338D;
    }
    function getCETHAddress() public pure returns (address cEth) {
        cEth = 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5;
    }
    function getCUSDCAddress() public pure returns (address cUsdc) {
        cUsdc = 0x39AA39c021dfbaE8faC545936693aC917d5E7563;
    }
    function getAddressAdmin() public pure returns (address admin) {
        admin = 0xa7615CD307F323172331865181DC8b80a2834324;
    }
    function enterMarket(address cErc20) internal {
        ComptrollerInterface troller = ComptrollerInterface(getComptrollerAddress());
        address[] memory markets = troller.getAssetsIn(address(this));
        bool isEntered = false;
        for (uint i = 0; i < markets.length; i++) {
            if (markets[i] == cErc20) {
                isEntered = true;
            }
        }
        if (!isEntered) {
            address[] memory toEnter = new address[](1);
            toEnter[0] = cErc20;
            troller.enterMarkets(toEnter);
        }
    }
    function setApproval(address erc20, uint srcAmt, address to) internal {
        ERC20Interface erc20Contract = ERC20Interface(erc20);
        uint tokenAllowance = erc20Contract.allowance(address(this), to);
        if (srcAmt > tokenAllowance) {
            erc20Contract.approve(to, 2**255);
        }
    }
}
