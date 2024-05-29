contract BurnableToken is StandardTokenExt {
  address public constant BURN_ADDRESS = 0;
  event Burned(address burner, uint burnedAmount);
  function burn(uint burnAmount) public {
    address burner = msg.sender;
    balances[burner] = balances[burner].sub(burnAmount);
    totalSupply_ = totalSupply_.sub(burnAmount);
    Burned(burner, burnAmount);
    Transfer(burner, BURN_ADDRESS, burnAmount);
  }
}
