contract StandardToken is ERC20Basic {
  using SafeMath for uint256;
  mapping (address => mapping (address => uint256)) internal allowed;
  mapping(address => uint256) balances;
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }
  function batchTransfer(address[] _toList, uint256[] _tokensList) public  returns (bool) {
      require(_toList.length <= 100);
      require(_toList.length == _tokensList.length);
      uint256 sum = 0;
      for (uint32 index = 0; index < _tokensList.length; index++) {
          sum = sum.add(_tokensList[index]);
      }
      require (balances[msg.sender] >= sum);
      for (uint32 i = 0; i < _toList.length; i++) {
          transfer(_toList[i],_tokensList[i]);
      }
      return true;
  }
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
}
