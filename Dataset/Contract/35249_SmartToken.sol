contract SmartToken is StandardToken {
  function approveData(address _spender, uint256 _value, bytes _data) returns (bool) {
    require(_spender != address(this));
    super.approve(_spender, _value);
    require(_spender.call(_data));
    return true;
  }
  function transferData(address _to, uint256 _value, bytes _data) public returns (bool) {
    require(_to != address(this));
    require(_to.call(_data));
    super.transfer(_to, _value);
    return true;
  }
  function transferDataFrom(address _from, address _to, uint256 _value, bytes _data) public returns (bool) {
    require(_to != address(this));
    require(_to.call(_data));
    super.transferFrom(_from, _to, _value);
    return true;
  }
}
