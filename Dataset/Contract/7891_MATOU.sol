contract MATOU is StandardToken {
  string public name    = "MATOU Token";
  string public symbol  = "MTB";
  uint8 public decimals = 18;
  uint256 public constant INITIAL_SUPPLY = 1000000000;
  event Burn(address indexed _from, uint256 _tokenDestroyed, uint256 _timestamp);
  function MATOU() public {
    totalSupply_ = INITIAL_SUPPLY * (10 ** uint256(decimals));
    balances[msg.sender] = totalSupply_;
  }
  function burn(uint256 _burntAmount) public returns (bool success) {
    require(balances[msg.sender] >= _burntAmount && _burntAmount > 0);
    balances[msg.sender] = balances[msg.sender].sub(_burntAmount);
    totalSupply_ = totalSupply_.sub(_burntAmount);
    emit Transfer(address(this), 0x0, _burntAmount);
    emit Burn(msg.sender, _burntAmount, block.timestamp);
    return true;
  }
}
