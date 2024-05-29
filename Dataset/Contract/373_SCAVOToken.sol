contract SCAVOToken is StandardToken, MintableToken, PausableToken, BurnableToken {
  string public constant name = "SCAVO Token";
  string public constant symbol = "SCAVO";
  string public constant version = "1.1";
  uint8 public constant decimals = 18;
  uint256 public constant INITIAL_SUPPLY = 200000000 * (10 ** uint256(decimals));
  constructor() public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    emit Transfer(address(0), msg.sender, INITIAL_SUPPLY);
  }
}
