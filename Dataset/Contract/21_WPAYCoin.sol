contract WPAYCoin is StandardToken {
  string public constant name = "WPAYCoin";
  string public constant symbol = "WPY";
  uint8 public constant decimals = 6;
  uint256 public constant INITIAL_SUPPLY = 600000000 * (10 ** uint256(decimals));
  function WPAYCoin() public {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }
}
