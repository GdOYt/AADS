contract EroStandardToken is EROSCOINToken, Ownable {
    using EROMaths for uint256;
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => bool) public frozenAccount;
    event FrozenFunds(address target, bool frozen);
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
    function freezeAccount(address target, bool freeze) onlyOwner {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }
    function transfer(address _to, uint256 _value) returns (bool success) {
        if (frozenAccount[msg.sender]) return false;
        require(
            (balances[msg.sender] >= _value)  
            && (_value > 0)  
            && (_to != address(0))  
            && (balances[_to].add(_value) >= balances[_to])  
            && (msg.data.length >= (2 * 32) + 4));  
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (frozenAccount[msg.sender]) return false;
        require(
            (allowed[_from][msg.sender] >= _value)  
            && (balances[_from] >= _value)  
            && (_value > 0)  
            && (_to != address(0))  
            && (balances[_to].add(_value) >= balances[_to])  
            && (msg.data.length >= (2 * 32) + 4)  
        );
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }
    function approve(address _spender, uint256 _value) returns (bool success) {
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }
}
