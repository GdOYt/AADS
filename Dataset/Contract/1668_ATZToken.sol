contract ATZToken is StandardToken {
  string public constant name = "Atomz Token";
  string public constant symbol = "ATZ";
  uint8 public constant decimals = 18;
  uint256 public constant INITIAL_SUPPLY = 25000000 * (10 ** uint256(decimals));
  constructor() public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    emit Transfer(address(0), msg.sender, INITIAL_SUPPLY);
  }
}
