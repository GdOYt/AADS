contract Haltable is Ownable {
    bool public halted;
    modifier inNormalState {
        assert(!halted);
        _;
    }
    modifier inEmergencyState {
        assert(halted);
        _;
    }
    function halt() external onlyOwner inNormalState {
        halted = true;
    }
    function resume() external onlyOwner inEmergencyState {
        halted = false;
    }
}
