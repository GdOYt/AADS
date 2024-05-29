contract ERC827Token is ERC827, StandardToken {
  function approve(address _spender, uint256 _value, bytes _data) public returns (bool) {
    require(!frozenAccount[msg.sender] && !frozenAccount[_spender]);
    require(_spender != address(this));
    super.approve(_spender, _value);
    require(_spender.call(_data));
    return true;
  }
  function transfer(address _to, uint256 _value, bytes _data) public returns (bool) {
    require(_to != address(this));
    super.transfer(_to, _value);
    require(_to.call(_data));
    return true;
  }
  function transferFrom(address _from, address _to, uint256 _value, bytes _data) public returns (bool) {
    require(_to != address(this));
    super.transferFrom(_from, _to, _value);
    require(_to.call(_data));
    return true;
  }
  function increaseApproval(address _spender, uint _addedValue, bytes _data) public returns (bool) {
    require(_spender != address(this));
    super.increaseApproval(_spender, _addedValue);
    require(_spender.call(_data));
    return true;
  }
  function decreaseApproval(address _spender, uint _subtractedValue, bytes _data) public returns (bool) {
    require(_spender != address(this));
    super.decreaseApproval(_spender, _subtractedValue);
    require(_spender.call(_data));
    return true;
  }
}
