contract StandardToken is Token {
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != 0x0);
        require(_to != address(this));
        require(balances[msg.sender] >= _value);
        require(balances[_to] + _value >= balances[_to]);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool)
    {
        require(_from != 0x0);
        require(_to != 0x0);
        require(_to != address(this));
        require(balances[_from] >= _value);
        require(allowed[_from][msg.sender] >= _value);
        require(balances[_to] + _value >= balances[_to]);
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }
    function approve(address _who, uint256 _value) public returns (bool) {
        require(_who != 0x0);
        require(_value == 0 || allowed[msg.sender][_who] == 0);
        allowed[msg.sender][_who] = _value;
        Approval(msg.sender, _who, _value);
        return true;
    }
    function allowance(address _owner, address _who) constant public returns (uint256)
    {
        return allowed[_owner][_who];
    }
    function balanceOf(address _owner) constant public returns (uint256) {
        return balances[_owner];
    }
}
