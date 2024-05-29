contract TCPC is StandardToken {
  string public constant name = "Test Coin PrimeCore"; 
  string public constant symbol = "TCPC"; 
  uint8 public constant decimals = 8; 
  address public constant tokenOwner = 0x3c9da12eda40d69713ef7c6129e5ebd75983ac3d;
  uint256 public constant INITIAL_SUPPLY = 6750000000 * (10 ** uint256(decimals));
  function TCPC() public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[tokenOwner] = INITIAL_SUPPLY;
    emit Transfer(0x0, tokenOwner, INITIAL_SUPPLY);
  }
}
