contract BSEToken is MintableToken {
  string public constant name = " BLACK SNAIL ENERGY ";
  string public constant symbol = "BSE";
  uint32 public constant decimals = 18;
  event Burn(address indexed burner, uint256 value);
  function burn(uint256 _value) public {
    require(_value > 0);
    require(_value <= balances[msg.sender]);
    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_value);
    totalSupply = totalSupply.sub(_value);
    Burn(burner, _value);
  }
}
