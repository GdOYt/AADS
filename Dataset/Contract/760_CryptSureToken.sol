contract CryptSureToken is StandardToken {
  string public name    = "CryptSureToken";
  string public symbol  = "CPST";
  uint8 public decimals = 18;
  uint256 public constant INITIAL_SUPPLY = 50000000;
  constructor() public {
    totalSupply_ = INITIAL_SUPPLY * (10 ** uint256(decimals));
    balances[msg.sender] = totalSupply_;
    transfer(msg.sender, totalSupply_);
  }  
	function transfer(address _to, uint256 _value) public returns (bool) {
		require(_to != address(this) );
		super.transfer(_to, _value);
	}  
}
