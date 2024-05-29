contract token {
	function transferFrom(address sender, address receiver, uint amount) public returns(bool success) {}
	function transfer(address receiver, uint amount) public returns(bool success) {}
	function balanceOf(address holder) public constant returns(uint) {}
}
