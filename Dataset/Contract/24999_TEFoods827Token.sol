contract TEFoods827Token is TEFoodsToken, ERC827 {
  function approve(address _spender, uint256 _value, bytes _data) public returns (bool) {
    super.approve(_spender, _value);
    require(_spender.call(_data));
    return true;
  }
  function transfer(address _to, uint256 _value, bytes _data) public returns (bool) {
    super.transfer(_to, _value);
    require(_to.call(_data));
    return true;
  }
  function transferFrom(address _from, address _to, uint256 _value, bytes _data) public returns (bool) {
    super.transferFrom(_from, _to, _value);
    require(_to.call(_data));
    return true;
  }
}
