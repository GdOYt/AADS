contract SingularDTVToken is StandardToken {
    string public version = "0.1.0";
    AbstractSingularDTVFund public singularDTVFund;
    string public name;
    string public symbol;
    uint8 public constant decimals = 18;
    function transfer(address to, uint256 value)
        returns (bool)
    {
        singularDTVFund.softWithdrawRewardFor(msg.sender);
        singularDTVFund.softWithdrawRewardFor(to);
        return super.transfer(to, value);
    }
    function transferFrom(address from, address to, uint256 value)
        returns (bool)
    {
        singularDTVFund.softWithdrawRewardFor(from);
        singularDTVFund.softWithdrawRewardFor(to);
        return super.transferFrom(from, to, value);
    }
    function SingularDTVToken(address sDTVFundAddr, address _wallet, string _name, string _symbol, uint _totalSupply) {
        if(sDTVFundAddr == 0 || _wallet == 0) {
            revert();
        }
        balances[_wallet] = _totalSupply;
        totalSupply = _totalSupply;
        name = _name;
        symbol = _symbol;
        singularDTVFund = AbstractSingularDTVFund(sDTVFundAddr);
        Transfer(this, _wallet, _totalSupply);
    }
}
