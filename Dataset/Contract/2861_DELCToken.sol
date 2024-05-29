contract DELCToken is BurnableToken, MintableToken, PausableToken {
  string public name;
  string public symbol;
  uint8 public decimals;
  constructor() public {
    name = "DELC Relation Person Token";
    symbol = "DELC";
    decimals = 18;
    totalSupply = 10000000000 * 10 ** uint256(decimals);
    balances[msg.sender] = totalSupply;
    emit Transfer(address(0), msg.sender, totalSupply);
  }
}
