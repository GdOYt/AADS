contract LifToken is SmartToken, MintableToken, Pausable {
  string public constant NAME = "Líf";
  string public constant SYMBOL = "LIF";
  uint public constant DECIMALS = 18;
  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }
  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.approve(_spender, _value);
  }
  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }
  function approveData(address spender, uint256 value, bytes data) public whenNotPaused returns (bool) {
    return super.approveData(spender, value, data);
  }
  function transferData(address to, uint256 value, bytes data) public whenNotPaused returns (bool) {
    return super.transferData(to, value, data);
  }
  function transferDataFrom(address from, address to, uint256 value, bytes data) public whenNotPaused returns (bool) {
    return super.transferDataFrom(from, to, value, data);
  }
  function burn(uint256 _value) public whenNotPaused {
    require(_value > 0);
    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_value);
    totalSupply = totalSupply.sub(_value);
    Burn(burner, _value);
    Transfer(burner, address(0), _value);
  }
  event Burn(address indexed burner, uint value);
}
