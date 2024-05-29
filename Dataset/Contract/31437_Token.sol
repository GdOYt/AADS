contract Token is ERC223TokenCompatible, StandardToken, StartToken, HumanStandardToken, BurnToken, OriginToken {
	uint256 public totalSupply;
	uint256 public initialSupply;
	uint8 public decimals;
    string public name;
    string public symbol;
    function Token(uint256 _totalSupply, uint8 _decimals, string _name, string _symbol) public {
        decimals = _decimals;
        totalSupply = _totalSupply * 10 ** uint(decimals);  
        initialSupply = totalSupply;
		name = _name;
		symbol = _symbol;
        balances[msg.sender] = totalSupply;
        Transfer(0, msg.sender, totalSupply);
    }
}
