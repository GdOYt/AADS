contract SmartToken is ISmartToken, Owned, ERC20Token, TokenHolder {
    string public version = '0.3';
    bool public transfersEnabled = true;    
    event NewSmartToken(address _token);
    event Issuance(uint256 _amount);
    event Destruction(uint256 _amount);
    constructor(string _name, string _symbol, uint8 _decimals)
        public
        ERC20Token(_name, _symbol, _decimals)
    {
        emit NewSmartToken(address(this));
    }
    modifier transfersAllowed {
        assert(transfersEnabled);
        _;
    }
    function disableTransfers(bool _disable) public ownerOnly {
        transfersEnabled = !_disable;
    }
    function issue(address _to, uint256 _amount)
        public
        ownerOnly
        validAddress(_to)
        notThis(_to)
    {
        totalSupply = safeAdd(totalSupply, _amount);
        balanceOf[_to] = safeAdd(balanceOf[_to], _amount);
        emit Issuance(_amount);
        emit Transfer(this, _to, _amount);
    }
    function destroy(address _from, uint256 _amount) public {
        require(msg.sender == _from || msg.sender == owner); 
        balanceOf[_from] = safeSub(balanceOf[_from], _amount);
        totalSupply = safeSub(totalSupply, _amount);
        emit Transfer(_from, this, _amount);
        emit Destruction(_amount);
    }
    function transfer(address _to, uint256 _value) public transfersAllowed returns (bool success) {
        assert(super.transfer(_to, _value));
        return true;
    }
    function transferFrom(address _from, address _to, uint256 _value) public transfersAllowed returns (bool success) {
        assert(super.transferFrom(_from, _to, _value));
        return true;
    }
}
