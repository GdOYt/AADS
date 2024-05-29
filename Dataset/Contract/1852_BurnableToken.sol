contract BurnableToken is BasicToken {
  event Burn(address indexed burner, uint256 value);
  function burn(uint256 _value) public {
    _burn(msg.sender, _value);
  }
  function _burn(address _who, uint256 _value) internal {
    require(_value <= balances[_who]);
    balances[_who] = balances[_who].sub(_value);
    totalSupply = totalSupply.sub(_value);
    Burn(_who, _value);
    Transfer(_who, address(0), _value);
  }
}
