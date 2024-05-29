contract BurnableToken is BasicToken, OwnableToken {
  event Burn(address indexed burner, uint256 value);
  function burn(uint256 _value) public onlyOwner {
    require(_value <= balances[msg.sender]);
    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    Burn(burner, _value);
    Transfer(burner, address(0), _value);
  }
}
