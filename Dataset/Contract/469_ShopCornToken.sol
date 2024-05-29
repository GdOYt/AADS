contract ShopCornToken is StandardToken {
  string public constant name = "ShopCornToken";
  string public constant symbol = "SHC";           
  uint8 public constant decimals = 8;
  uint256 public constant INITIAL_SUPPLY = 2000000000 * (10 ** uint256(decimals));
  constructor() public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    emit Transfer(address(0), msg.sender, INITIAL_SUPPLY);
  }
}
