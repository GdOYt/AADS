contract ERC223 is ERC20Interface {
	function transfer(address to, uint value, bytes data) public returns (bool);
	event Transfer(address indexed from, address indexed to, uint tokens);
	event Transfer(address indexed from, address indexed to, uint value, bytes data);
}
