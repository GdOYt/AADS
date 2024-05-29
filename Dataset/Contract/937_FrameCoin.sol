contract FrameCoin is PausableToken {
  string public constant name = "FrameCoin";
  string public constant symbol = "FRAC";
  uint8 public constant decimals = 18;
  uint256 public constant INITIAL_SUPPLY = 265e6 * 10**uint256(decimals);
  function FrameCoin() public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    Transfer(0x0, msg.sender, INITIAL_SUPPLY);
  }
}
