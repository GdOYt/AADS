contract StartToken is Startable, ERC223TokenCompatible, StandardToken {
  function transfer(address _to, uint256 _value) public whenStarted returns (bool) {
    return super.transfer(_to, _value);
  }
  function transfer(address _to, uint256 _value, bytes _data) public whenStarted returns (bool) {
    return super.transfer(_to, _value, _data);
  }
  function transfer(address _to, uint256 _value, bytes _data, string _custom_fallback) public whenStarted returns (bool) {
    return super.transfer(_to, _value, _data, _custom_fallback);
  }
  function transferFrom(address _from, address _to, uint256 _value) public whenStarted returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }
  function approve(address _spender, uint256 _value) public whenStarted returns (bool) {
    return super.approve(_spender, _value);
  }
  function increaseApproval(address _spender, uint _addedValue) public whenStarted returns (bool success) {
    return super.increaseApproval(_spender, _addedValue);
  }
  function decreaseApproval(address _spender, uint _subtractedValue) public whenStarted returns (bool success) {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}
