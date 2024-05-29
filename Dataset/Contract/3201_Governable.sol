contract Governable {
    event Pause();
    event Unpause();
    address public governor;
    bool public paused = false;
    constructor() public {
        governor = msg.sender;
    }
    function setGovernor(address _gov) public onlyGovernor {
        governor = _gov;
    }
    modifier onlyGovernor {
        require(msg.sender == governor);
        _;
    }
    modifier whenNotPaused() {
        require(!paused);
        _;
    }
    modifier whenPaused() {
        require(paused);
        _;
    }
    function pause() onlyGovernor whenNotPaused public {
        paused = true;
        emit Pause();
    }
    function unpause() onlyGovernor whenPaused public {
        paused = false;
        emit Unpause();
    }
}
