contract SmartWallet {
    using SmartWalletLib for SmartWalletLib.Wallet;
    SmartWalletLib.Wallet public wallet;
    event TransferToUserWithdrawalAccount(address _token, address _userWithdrawalAccount, uint _amount, address _feesToken, address _feesAccount, uint _fee);
    event SetUserWithdrawalAccount(address _userWithdrawalAccount);
    event PerformUserWithdraw(address _token, address _userWithdrawalAccount, uint _amount);
    constructor (address _operator, address _feesAccount) public {
        wallet.initWallet(_operator, _feesAccount);
    }
    function setUserWithdrawalAccount(address _userWithdrawalAccount) public {
        wallet.setUserWithdrawalAccount(_userWithdrawalAccount);
    }
    function transferToUserWithdrawalAccount(IERC20Token _token, uint _amount, IERC20Token _feesToken, uint _fee) public {
        wallet.transferToUserWithdrawalAccount(_token, _amount, _feesToken, _fee);
    }
    function requestWithdraw() public {
        wallet.requestWithdraw();
    }
    function performUserWithdraw(IERC20Token _token) public {
        wallet.performUserWithdraw(_token);
    }
}
