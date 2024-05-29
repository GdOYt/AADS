contract Ownable {
	address public owner;
	address public pendingOwner;
	address public operator;
	event OwnershipTransferred(
		address indexed previousOwner,
		address indexed newOwner
	);
	constructor() public {
		owner = msg.sender;
	}
	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}
	modifier onlyPendingOwner() {
		require(msg.sender == pendingOwner);
		_;
	}
	modifier ownerOrOperator {
		require(msg.sender == owner || msg.sender == operator);
		_;
	}
	function transferOwnership(address newOwner) onlyOwner public {
		pendingOwner = newOwner;
	}
	function claimOwnership() onlyPendingOwner public {
		emit OwnershipTransferred(owner, pendingOwner);
		owner = pendingOwner;
		pendingOwner = address(0);
	}
	function setOperator(address _operator) onlyOwner public {
		operator = _operator;
	}
}
