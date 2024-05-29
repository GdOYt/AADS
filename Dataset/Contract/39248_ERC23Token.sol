contract ERC23Token is ERC23 {
  mapping(address => uint256) balances;
  mapping (address => mapping (address => uint256)) allowed;
  string public name;
  string public symbol;
  uint8 public decimals;
  uint256 public totalSupply;
  function name() constant returns (string _name) {
      return name;
  }
  function symbol() constant returns (string _symbol) {
      return symbol;
  }
  function decimals() constant returns (uint8 _decimals) {
      return decimals;
  }
  function totalSupply() constant returns (uint256 _totalSupply) {
      return totalSupply;
  }
  function transfer(address _to, uint256 _value, bytes _data) returns (bool success) {
    if(isContract(_to)) {
        transferToContract(_to, _value, _data);
    }
    else {
        transferToAddress(_to, _value, _data);
    }
    return true;
  }
  function transfer(address _to, uint256 _value) returns (bool success) {
    bytes memory empty;
    if(isContract(_to)) {
        transferToContract(_to, _value, empty);
    }
    else {
        transferToAddress(_to, _value, empty);
    }
    return true;
  }
  function transferToAddress(address _to, uint256 _value, bytes _data) private returns (bool success) {
    balances[msg.sender] -= _value;
    balances[_to] += _value;
    Transfer(msg.sender, _to, _value);
    Transfer(msg.sender, _to, _value, _data);
    return true;
  }
  function transferToContract(address _to, uint256 _value, bytes _data) private returns (bool success) {
    balances[msg.sender] -= _value;
    balances[_to] += _value;
    ContractReceiver reciever = ContractReceiver(_to);
    reciever.tokenFallback(msg.sender, _value, _data);
    Transfer(msg.sender, _to, _value);
    Transfer(msg.sender, _to, _value, _data);
    return true;
  }
  function isContract(address _addr) private returns (bool is_contract) {
      _addr = _addr;
      uint256 length;
      assembly {
            length := extcodesize(_addr)
        }
        if(length>0) {
            return true;
        }
        else {
            return false;
        }
    }
  function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
    var _allowance = allowed[_from][msg.sender];
    if(_value > _allowance) {
        throw;
    }
    balances[_to] += _value;
    balances[_from] -= _value;
    allowed[_from][msg.sender] -= _value;
    Transfer(_from, _to, _value);
    return true;
  }
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }
  function approve(address _spender, uint256 _value) returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
}
