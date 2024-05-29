contract KWATT_Token is PausableToken {
    string public name = "4NEW";
    string public symbol = "KWATT";
    uint8 public decimals = 18;
    uint public INITIAL_SUPPLY = 300000000000000000000000000;
constructor() public {
  totalSupply_ = INITIAL_SUPPLY;
  balances[msg.sender] = totalSupply_;
}
}
