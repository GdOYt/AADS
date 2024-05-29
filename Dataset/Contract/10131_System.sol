contract System {
	using SafeMath for uint256;
	address owner;
	modifier onlyOwner() {
		if (msg.sender != owner) {
			error('System: onlyOwner function called by user that is not owner');
		} else {
			_;
		}
	}
	function error(string _error) internal {
		revert(_error);
	}
	function whoAmI() public constant returns (address) {
		return msg.sender;
	}
	function timestamp() public constant returns (uint256) {
		return block.timestamp;
	}
	function contractBalance() public constant returns (uint256) {
		return address(this).balance;
	}
	constructor() public {
		owner = msg.sender;
		if(owner == 0x0) error('System constructor: Owner address is 0x0');  
	}
	event Error(string _error);
	event DebugUint256(uint256 _data);
}
