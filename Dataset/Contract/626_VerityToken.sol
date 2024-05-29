contract VerityToken is StandardToken {
  string public name = "VerityToken";
  string public symbol = "VTY";
  uint8 public decimals = 18;
  uint public INITIAL_SUPPLY = 500000000 * 10 ** uint(decimals);
  function VerityToken() public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }
}
