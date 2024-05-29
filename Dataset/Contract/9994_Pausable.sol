contract Pausable is Ownable {
    bool public paused = true;
    modifier whenNotPaused() {
        require(!paused);
        _;
    }
    modifier whenPaused {
        require(paused);
        _;
    }
    function pause() public onlyOwner whenNotPaused {
        paused = true;
    }
    function unpause() public onlyOwner whenPaused {
        paused = false;
    }
}
