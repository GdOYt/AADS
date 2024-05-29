contract Haltable is System {
	bool public halted;
	modifier stopInEmergency {
		if (halted) {
			error('Haltable: stopInEmergency function called and contract is halted');
		} else {
			_;
		}
	}
	modifier onlyInEmergency {
		if (!halted) {
			error('Haltable: onlyInEmergency function called and contract is not halted');
		} {
			_;
		}
	}
	function halt() external onlyOwner {
		halted = true;
		emit Halt(true, msg.sender, timestamp());  
	}
	function unhalt() external onlyOwner onlyInEmergency {
		halted = false;
		emit Halt(false, msg.sender, timestamp());  
	}
	event Halt(bool _switch, address _halter, uint256 _timestamp);
}
