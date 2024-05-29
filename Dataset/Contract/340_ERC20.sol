contract ERC20 {
	uint256 public totalSupply;
	function balanceOf(address who) public view returns (uint256 balance);
	function allowance(address owner, address spender) public view returns (uint256 remaining);
	function transfer(address to, uint256 value) public returns (bool success);
	function approve(address spender, uint256 value) public returns (bool success);
	function transferFrom(address from, address to, uint256 value) public returns (bool success);
	event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
