contract BatchTokensTransfer is Ownable {
    constructor () public Ownable(msg.sender) {}
    function batchTokensTransfer(IERC20Token _token, address[] _usersWithdrawalAccounts, uint256[] _amounts) 
        public
        ownerOnly()
        {
            require(_usersWithdrawalAccounts.length == _amounts.length);
            for (uint i = 0; i < _usersWithdrawalAccounts.length; i++) {
                if (_usersWithdrawalAccounts[i] != 0x0) {
                    _token.transfer(_usersWithdrawalAccounts[i], _amounts[i]);
                }
            }
        }
    function transferToken(IERC20Token _token, address _userWithdrawalAccount, uint256 _amount)
        public
        ownerOnly()
        {
            require(_userWithdrawalAccount != 0x0 && _amount > 0);
            _token.transfer(_userWithdrawalAccount, _amount);
        }
    function transferAllTokensToOwner(IERC20Token _token)
        public
        ownerOnly()
        {
            uint256 _amount = _token.balanceOf(this);
            _token.transfer(owner, _amount);
        }
}
