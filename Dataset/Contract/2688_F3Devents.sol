contract F3Devents {
  event Winner(address winner, uint256 pool, address revealer);
  event Buy(address buyer, uint256 keys, uint256 cost);
  event Sell(address from, uint256 price, uint256 count);
  event Bought(address buyer, address from, uint256 amount, uint256 price);
}
