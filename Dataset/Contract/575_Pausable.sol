contract Pausable is Ownable {
	event Pause();
	event Unpause();
	bool public paused = false;
	modifier whenNotPaused() {
		require(!paused);
		_;
	}
	modifier whenPaused {
		require(paused);
		_;
	}
	function pause() onlyOwner whenNotPaused public returns (bool) {
		paused = true;
		emit Pause();
		return true;
	}
	function unpause() onlyOwner whenPaused public returns (bool) {
		paused = false;
		emit Unpause();
		return true;
	}
}
