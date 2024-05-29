contract owned {
	address public owner;
	function owned() public {
		owner = msg.sender;
	}
	modifier onlyOwner {
		require(msg.sender == owner);
		_;
	}
	function transferOwnership(address newAdmin) onlyOwner public {
		owner = newAdmin;
	}
}
