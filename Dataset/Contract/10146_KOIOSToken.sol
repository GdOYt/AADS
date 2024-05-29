contract KOIOSToken is StandardToken, Ownable {
	using SafeMath for uint256;
	string public name = "KOIOS";
	string public symbol = "KOI";
	uint256 public decimals = 5;
	uint256 public totalSupply = 1000000000 * (10 ** uint256(decimals));
	function KOIOSToken(string _name, string _symbol, uint256 _decimals, uint256 _totalSupply) public {
		name = _name;
		symbol = _symbol;
		decimals = _decimals;
		totalSupply = _totalSupply;
		totalSupply_ = _totalSupply;
		balances[msg.sender] = totalSupply;
	}
	function () public payable {
		revert();
	}
}
