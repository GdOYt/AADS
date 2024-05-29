contract NamoToken is StandardToken, PausableToken {
  string public constant name = "Namo Coin";
  string public constant symbol = "NAMO";
  uint8 public constant decimals = 8;
  uint256 public constant initialSupply = SafeMath.mul(56000000000000 , 1 ether);
    function NamoToken () {
        totalSupply_ = initialSupply;
        balances[owner] = initialSupply;
    }
}
