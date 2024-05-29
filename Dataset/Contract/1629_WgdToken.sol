contract WgdToken is StandardBurnableToken {
  string public constant name = "webGold";
  string public constant symbol = "WGD";
  uint8 public constant decimals = 18;
  uint256 constant TOTAL = 387500000000000000000000000;
  constructor() public {
    balances[msg.sender] = TOTAL;
    totalSupply_ = TOTAL;
    emit Transfer(address(0), msg.sender, TOTAL);
  }
}
