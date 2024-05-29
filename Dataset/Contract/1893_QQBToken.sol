contract QQBToken is StandardToken {
    string public name = "Qualified Quality Block ";
    string public symbol = "QQB";
    uint public decimals = 8;
	uint256 public constant total= 1000000000 * (10 ** uint256(decimals));
	 function QQBToken(address owner) {
		balances[owner] = total;
		totalSupply = total;
  }
}
