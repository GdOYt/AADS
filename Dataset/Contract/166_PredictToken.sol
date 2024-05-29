contract PredictToken is StandardToken{
  address public owner;
  string public name = 'PredictToken';
  string public symbol = 'PT';
  uint8 public decimals = 8;
  uint256 constant total = 100000000000000000; 
  constructor() public {
    owner = msg.sender;
    totalSupply_ = total;
    balances[owner] = total;
  }
}
