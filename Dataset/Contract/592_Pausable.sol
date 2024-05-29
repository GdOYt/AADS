contract Pausable is Owned {
    uint public lastPauseTime;
    bool public paused;
    constructor(address _owner)
        Owned(_owner)
        public
    {
    }
    function setPaused(bool _paused)
        external
        onlyOwner
    {
        if (_paused == paused) {
            return;
        }
        paused = _paused;
        if (paused) {
            lastPauseTime = now;
        }
        emit PauseChanged(paused);
    }
    event PauseChanged(bool isPaused);
    modifier notPaused {
        require(!paused, "This action cannot be performed while the contract is paused");
        _;
    }
}
