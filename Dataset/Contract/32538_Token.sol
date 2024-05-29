contract Token is CanTransferTokens, SafeMath, CheckIfContract, useContractWeb {
  string public symbol = "SHC";
  string public name = "ShineCoin";
  uint8 public decimals = 18;
  uint256 public totalSupply = 190 * 1000000 * 1000000000000000000;
  mapping (address => mapping (address => uint256)) internal _allowance;
  event Approval(address indexed from, address indexed to, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value, bytes indexed data);
  function balanceOf(address _account) view public returns (uint256) {
    return Balances(balancesContract()).get(_account);
  }
  function allowance(address _from, address _to) view public returns (uint256 remaining) {
    return _allowance[_from][_to];
  }
  function balancesContract() view internal returns (address) {
    return web.getContractAddress("Balances");
  }
  function Token() public {
    bytes memory empty;
    Transfer(this, msg.sender, 190 * 1000000 * 1000000000000000000);
    Transfer(this, msg.sender, 190 * 1000000 * 1000000000000000000, empty);
  }
  function transfer(address _to, uint256 _value, bytes _data, string _custom_fallback) onlyPayloadSize(4 * 32) public returns (bool success) {
    if(isContract(_to)) {
      require(Balances(balancesContract()).get(msg.sender) >= _value);
      Balances(balancesContract()).transfer(msg.sender, _to, _value);
      ContractReceiver receiver = ContractReceiver(_to);
      require(receiver.call.value(0)(bytes4(keccak256(_custom_fallback)), msg.sender, _value, _data));
      Transfer(msg.sender, _to, _value);
      Transfer(msg.sender, _to, _value, _data);
      return true;
    } else {
      return transferToAddress(_to, _value, _data);
    }
  }
  function transfer(address _to, uint256 _value, bytes _data) onlyPayloadSize(3 * 32) public returns (bool success) {
    if(isContract(_to)) {
      return transferToContract(_to, _value, _data);
    }
    else {
      return transferToAddress(_to, _value, _data);
    }
  }
  function transfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) public returns (bool success) {
    bytes memory empty;
    if(isContract(_to)) {
      return transferToContract(_to, _value, empty);
    }
    else {
      return transferToAddress(_to, _value, empty);
    }
  }
  function transferToAddress(address _to, uint256 _value, bytes _data) internal returns (bool success) {
    require(Balances(balancesContract()).get(msg.sender) >= _value);
    Balances(balancesContract()).transfer(msg.sender, _to, _value);
    Transfer(msg.sender, _to, _value);
    Transfer(msg.sender, _to, _value, _data);
    return true;
  }
  function transferToContract(address _to, uint256 _value, bytes _data) internal returns (bool success) {
    require(Balances(balancesContract()).get(msg.sender) >= _value);
    Balances(balancesContract()).transfer(msg.sender, _to, _value);
    ContractReceiver receiver = ContractReceiver(_to);
    receiver.tokenFallback(msg.sender, _value, _data);
    Transfer(msg.sender, _to, _value);
    Transfer(msg.sender, _to, _value, _data);
    return true;
  }
  function transferFrom(address _from, address _to, uint256 _value) onlyPayloadSize(3 * 32) public returns (bool) {
    bytes memory empty;
    require(_value > 0 && _allowance[_from][msg.sender] >= _value && Balances(balancesContract()).get(_from) >= _value);
    _allowance[_from][msg.sender] = sub(_allowance[_from][msg.sender], _value);
    if(msg.sender != _to && isContract(_to)) {
      Balances(balancesContract()).transfer(_from, _to, _value);
      ContractReceiver receiver = ContractReceiver(_to);
      receiver.tokenFallback(_from, _value, empty);
    } else {
      Balances(balancesContract()).transfer(_from, _to, _value);
    }
    Transfer(_from, _to, _value);
    Transfer(_from, _to, _value, empty);
    return true;
  }
  function approve(address _spender, uint256 _value) onlyPayloadSize(2 * 32) public returns (bool) {
    _allowance[msg.sender][_spender] = add(_allowance[msg.sender][_spender], _value);
    Approval(msg.sender, _spender, _value);
    return true;
  }
}
