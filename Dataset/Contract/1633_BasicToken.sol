contract BasicToken is ERC20, Pausable {
  using SafeMath for uint256;
  mapping(address => uint256) balances;
  mapping(address => mapping(address => uint256)) allowed;
  function _transfer(address _from, address _to, uint256 _value) internal returns(bool success) {
    require(_to != 0x0);
    require(_value > 0);
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }
  function transfer(address _to, uint256 _value) public whenNotPaused returns(bool success) {
    require(balances[msg.sender] >= _value);
    return _transfer(msg.sender, _to, _value);
  }
  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns(bool success) {
    require(balances[_from] >= _value);
    require(allowed[_from][msg.sender] >= _value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    return _transfer(_from, _to, _value);
  }
  function balanceOf(address _owner) constant public returns(uint256 balance) {
    return balances[_owner];
  }
  function approve(address _spender, uint256 _value) public returns(bool success) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }
  function allowance(address _owner, address _spender) constant public returns(uint256 remaining) {
    return allowed[_owner][_spender];
  }
}
