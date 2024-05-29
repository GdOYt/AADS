contract Pausable is Ownable {
    bool public paused = false;
    event Pause();
    event Unpause();
    modifier whenNotPaused() { require(!paused); _; }
    modifier whenPaused() { require(paused); _; }
    function pause() onlyOwner whenNotPaused public {
        paused = true;
        Pause();
    }
    function unpause() onlyOwner whenPaused public {
        paused = false;
        Unpause();
    }
}
