contract HITToken is CappedToken {
  string public name = "HIT TOKEN";
  string public symbol = "HIT";
  uint256 public decimals = 18;
  uint256 public cap = 1250000000  ether;
  constructor() CappedToken(cap) public {}
}
