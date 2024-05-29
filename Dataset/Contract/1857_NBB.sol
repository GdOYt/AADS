contract NBB is StandardToken {
  string public constant name = "New Bithank Bonus"; 
  string public constant symbol = "NBB"; 
  uint8 public constant decimals = 18; 
  uint256 public constant INITIAL_SUPPLY = (10 ** 8 * 100) * (10 ** uint256(decimals));
  function NBB() public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);
  }
}
