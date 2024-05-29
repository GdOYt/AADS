contract CompoundSave is CompoundResolver {
    event LogSaveCompoundUsdc(uint srcETH, uint destDAI);
    event LogLeverageCompoundUsdc(uint srcDAI,uint destETH);
    function save(
        uint ethToFree,
        uint zrxEthAmt,
        bool isKyber,
        bytes memory calldataHexString,
        address[] memory ctokenAddr,
        uint[] memory ctokenFactor
    ) public
    {
        enterMarket(getCETHAddress());
        enterMarket(getCUSDCAddress());
        (,,,,uint maxWithdraw,) = getCompStats(address(this), ctokenAddr, ctokenFactor);
        uint ethToSwap = ethToFree < maxWithdraw ? ethToFree : maxWithdraw;
        redeemEth(ethToSwap);
        ERC20Interface wethContract = ERC20Interface(getAddressWETH());
        wethContract.deposit.value(zrxEthAmt)();
        wethContract.approve(getAddressZRXERC20(), zrxEthAmt);
        (bool swapSuccess,) = getAddressZRXExchange().call(calldataHexString);
        assert(swapSuccess);
        uint remainEth = sub(ethToSwap, zrxEthAmt);
        if (remainEth > 0 && isKyber) {
            KyberInterface(getAddressKyberProxy()).trade.value(remainEth)(
                    getAddressETH(),
                    remainEth,
                    getAddressUSDC(),
                    address(this),
                    2**255,
                    0,
                    getAddressAdmin()
                );
        }
        ERC20Interface usdcContract = ERC20Interface(getAddressUSDC());
        uint usdcBal = usdcContract.balanceOf(address(this));
        repayUsdc(usdcBal);
        emit LogSaveCompoundUsdc(ethToSwap, usdcBal);
    }
    function leverage(
        uint usdcToBorrow,
        uint zrxUsdcAmt,
        bytes memory calldataHexString,
        bool isKyber,
        address[] memory cTokenAddr,
        uint[] memory ctokenFactor
    ) public
    {
        enterMarket(getCETHAddress());
        enterMarket(getCUSDCAddress());
        (,,,uint borrowRemain,,) = getCompStats(address(this), cTokenAddr, ctokenFactor);
        uint usdcToSwap = getUsdcRemainBorrow(borrowRemain);
        usdcToSwap = usdcToSwap < usdcToBorrow ? usdcToSwap : usdcToBorrow;
        borrow(usdcToSwap);
        ERC20Interface usdcContract = ERC20Interface(getAddressUSDC());
        usdcContract.approve(getAddressZRXERC20(), zrxUsdcAmt);
        (bool swapSuccess,) = getAddressZRXExchange().call(calldataHexString);
        assert(swapSuccess);
        uint usdcRemain = sub(usdcToSwap, zrxUsdcAmt);
        if (usdcRemain > 0 && isKyber) {
            usdcContract.approve(getAddressKyberProxy(), usdcRemain);
            KyberInterface(getAddressKyberProxy()).trade.value(uint(0))(
                    getAddressUSDC(),
                    usdcRemain,
                    getAddressETH(),
                    address(this),
                    2**255,
                    0,
                    getAddressAdmin()
                );
        }
        ERC20Interface wethContract = ERC20Interface(getAddressWETH());
        uint wethBal = wethContract.balanceOf(address(this));
        wethContract.approve(getAddressWETH(), wethBal);
        wethContract.withdraw(wethBal);
        mintCEth(address(this).balance);
        emit LogLeverageCompoundUsdc(usdcToSwap, address(this).balance);
    }
}
