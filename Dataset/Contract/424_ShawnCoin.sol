contract ShawnCoin is DetailedERC20, StandardToken {
  constructor() public DetailedERC20("Shawn Coin", "SHAWN", 18) {
    totalSupply_ = 1000000000000000000000000000; 
    balances[msg.sender] = totalSupply_;
  }
}
