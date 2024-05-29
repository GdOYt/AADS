contract Pausable is Ownable {
    event Pause();
    event Unpause();
    bool public paused = false;
    modifier whenNotPaused() {
        if (msg.sender != owner) {
            require(!paused);
        }
        _;
    }
    modifier whenPaused() {
        if (msg.sender != owner) {
            require(paused);
        }
        _;
    }
    function pause() onlyOwner public {
        paused = true;
        emit Pause();
    }
    function unpause() onlyOwner public {
        paused = false;
        emit Unpause();
    }
}
