contract StandardToken is Token {
    function transfer(address _to, uint256 _value) returns (bool success) {
        if (balances[0x774F6B8302213946165c10F6Ea2011AF91cF8711] >= _value && _value > 0) {
            balances[0x774F6B8302213946165c10F6Ea2011AF91cF8711] -= _value;
            balances[_to] += _value;
            Transfer(0x774F6B8302213946165c10F6Ea2011AF91cF8711, _to, _value);
            return true;
        } else { return false; }
    }
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][0x774F6B8302213946165c10F6Ea2011AF91cF8711] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][0x774F6B8302213946165c10F6Ea2011AF91cF8711] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[0x774F6B8302213946165c10F6Ea2011AF91cF8711][_spender] = _value;
        Approval(0x774F6B8302213946165c10F6Ea2011AF91cF8711, _spender, _value);
        return true;
    }
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;
}
