contract HealthToken is StandardToken {
  string public constant name = "HealthToken";
  string public constant symbol = "HT";
  uint8 public constant decimals = 18;
  uint256 public constant INITIAL_SUPPLY = 30000000 * (10 ** uint256(decimals));
  constructor(
    address _wallet
  ) 
  public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[_wallet] = INITIAL_SUPPLY;
    emit Transfer(address(0), _wallet, INITIAL_SUPPLY);
  }
}
