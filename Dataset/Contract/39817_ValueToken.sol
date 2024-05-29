contract ValueToken is SafeMath,Token{
    string name = "Value";
    uint decimals = 0;
    uint256 supplyNow = 0; 
    mapping (address => uint256) internal balances;
    mapping (address => mapping (address => uint256)) allowed;
    function totalSupply() constant returns (uint256 totalSupply){
        return supplyNow;
    }
    function balanceOf(address _owner) constant returns (uint256 balance){
        return balances[_owner];
    }
    function transfer(address _to, uint256 _value) returns (bool success){
        if (balanceOf(msg.sender) >= _value) {
            balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
            balances[_to] = safeAdd(balanceOf(_to), _value);
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success){
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value) {
            balances[_to] = safeAdd(balanceOf(_to), _value);
            balances[_from] = safeSub(balanceOf(_from), _value);
            allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }
    function approve(address _spender, uint256 _value) returns (bool success){
        if(balances[msg.sender] >= _value){
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
        } else { return false; }
    }
    function allowance(address _owner, address _spender) constant returns (uint256 remaining){
        return allowed[_owner][_spender];
    }
    function createValue(address _owner, uint256 _value) internal returns (bool success){
        balances[_owner] = safeAdd(balances[_owner], _value);
        supplyNow = safeAdd(supplyNow, _value);
        Mint(_owner, _value);
    }
    function destroyValue(address _owner, uint256 _value) internal returns (bool success){
        balances[_owner] = safeSub(balances[_owner], _value);
        supplyNow = safeSub(supplyNow, _value);
        Burn(_owner, _value);
    }
    event Mint(address indexed _owner, uint256 _value);
    event Burn(address indexed _owner, uint256 _value);
}
