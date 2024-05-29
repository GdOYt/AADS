contract Owned {
	address public owner;
	constructor() public {
		owner = msg.sender;
	}
	modifier onlyOwner {
		require(msg.sender == owner,"O1- Owner only function");
		_;
	}
	function setOwner(address newOwner) onlyOwner public {
		owner = newOwner;
	}
}
