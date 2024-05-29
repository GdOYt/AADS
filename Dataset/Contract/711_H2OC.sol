contract H2OC is ERC20Token, Owned {
    string  public constant name = "H2O Chain";
    string  public constant symbol = "H2OC";
    uint256 public constant decimals = 18;
    uint256 public tokenDestroyed;
	event Burn(address indexed _from, uint256 _tokenDestroyed, uint256 _timestamp);
    function H2OC() public {
		totalToken = 60000000000000000000000000000;
		balances[msg.sender] = totalToken;
    }
    function transferAnyERC20Token(address _tokenAddress, address _recipient, uint256 _amount) public onlyOwner returns (bool success) {
        return ERC20(_tokenAddress).transfer(_recipient, _amount);
    }
    function burn (uint256 _burntAmount) public returns (bool success) {
    	require(balances[msg.sender] >= _burntAmount && _burntAmount > 0);
    	balances[msg.sender] = balances[msg.sender].sub(_burntAmount);
    	totalToken = totalToken.sub(_burntAmount);
    	tokenDestroyed = tokenDestroyed.add(_burntAmount);
    	require (tokenDestroyed <= 30000000000000000000000000000);
    	Transfer(address(this), 0x0, _burntAmount);
    	Burn(msg.sender, _burntAmount, block.timestamp);
    	return true;
	}
}
