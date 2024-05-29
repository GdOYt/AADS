contract BTX is BurnableToken, MintableToken {
  string public name = "BTX";
  string public symbol = "BTX";
  uint public decimals = 6;
  uint public INITIAL_SUPPLY = 20000000 * (10 ** decimals);
  constructor() public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }
}
