contract CRYPTOLANCERSToken is AdvanceToken {
  string public constant name = "CRYPTOLANCERS";
  string public constant symbol = "CLT";
  uint256 public constant decimals = 18;
  uint256 public constant INITIAL_SUPPLY = 100000000 * 10**decimals;
  constructor() public {
    totalSupply = INITIAL_SUPPLY;
    balances[0xEFeAc37a6a5Fb3630313742a2FADa6760C6FF653] = totalSupply;
 }
}
