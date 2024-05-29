contract WPAYReward is StandardToken {
  string public constant name = "WPAYReward";
  string public constant symbol = "WRT";
  uint8 public constant decimals = 4;
  uint256 public constant INITIAL_SUPPLY = 300000000 * (10 ** uint256(decimals));
  function WPAYReward() public {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }
}
