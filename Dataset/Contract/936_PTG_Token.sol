contract PTG_Token is StandardToken, Ownable {
  string public name;
  string public symbol;
  uint8 public decimals;
  uint256 public initialSupply;
  constructor() public {
    name = 'Petro.Global';
    symbol = 'PTG';
    decimals = 18;
    initialSupply = 5000000 * 10 ** uint256(decimals);
    totalSupply_ = initialSupply;
    balances[owner] = initialSupply;
    emit Transfer(0x0, owner, initialSupply);
  }
}
