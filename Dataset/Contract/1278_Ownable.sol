contract Ownable {
	address public owner;
	address public newOwner;
	event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);
	constructor() public {
		owner = msg.sender;
		newOwner = address(0);
	}
	modifier onlyOwner() {
		require(msg.sender == owner, "msg.sender == owner");
		_;
	}
	function transferOwnership(address _newOwner) public onlyOwner {
		require(address(0) != _newOwner, "address(0) != _newOwner");
		newOwner = _newOwner;
	}
	function acceptOwnership() public {
		require(msg.sender == newOwner, "msg.sender == newOwner");
		emit OwnershipTransferred(owner, msg.sender);
		owner = msg.sender;
		newOwner = address(0);
	}
}
