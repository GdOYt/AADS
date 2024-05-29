contract RestrictedShares is Shares {
    function RestrictedShares(
        string _name,
        string _symbol,
        uint _decimal,
        uint _creationTime
    ) Shares(_name, _symbol, _decimal, _creationTime) {}
    function transfer(address _to, uint _value)
        public
        returns (bool success)
    {
        require(msg.sender == address(this) || _to == address(this));
        uint codeLength;
        bytes memory empty;
        assembly {
            codeLength := extcodesize(_to)
        }
        require(balances[msg.sender] >= _value);  
        require(balances[_to] + _value >= balances[_to]);
        balances[msg.sender] = sub(balances[msg.sender], _value);
        balances[_to] = add(balances[_to], _value);
        if (codeLength > 0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, empty);
        }
        Transfer(msg.sender, _to, _value, empty);
        return true;
    }
    function transfer(address _to, uint _value, bytes _data)
        public
        returns (bool success)
    {
        require(msg.sender == address(this) || _to == address(this));
        uint codeLength;
        assembly {
            codeLength := extcodesize(_to)
        }
        require(balances[msg.sender] >= _value);  
        require(balances[_to] + _value >= balances[_to]);
        balances[msg.sender] = sub(balances[msg.sender], _value);
        balances[_to] = add(balances[_to], _value);
        if (codeLength > 0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }
        Transfer(msg.sender, _to, _value);
        return true;
    }
    function approve(address _spender, uint _value) public returns (bool) {
        require(msg.sender == address(this));
        require(_spender != 0x0);
        require(_value == 0 || allowed[msg.sender][_spender] == 0);
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
}
