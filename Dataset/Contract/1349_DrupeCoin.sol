contract DrupeCoin {
	function transfer(address to, uint tokens) public returns (bool success);
	function balanceOf(address tokenOwner) public constant returns (uint balance);
}
