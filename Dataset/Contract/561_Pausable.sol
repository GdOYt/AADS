contract Pausable is Ownable {
    bool public paused = false;
    modifier whenNotPaused() {
        require(!paused, "Contract is paused.");
        _;
    }
    modifier whenPaused() {
        require(paused);
        _;
    }
    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Pause();
    }
    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpause();
    }
    event Pause();
    event Unpause();
}
