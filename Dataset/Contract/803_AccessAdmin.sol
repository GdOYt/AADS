contract AccessAdmin {
    bool public isPaused = false;
    address public addrAdmin;  
    event AdminTransferred(address indexed preAdmin, address indexed newAdmin);
    constructor() public {
        addrAdmin = msg.sender;
    }  
    modifier onlyAdmin() {
        require(msg.sender == addrAdmin);
        _;
    }
    modifier whenNotPaused() {
        require(!isPaused);
        _;
    }
    modifier whenPaused {
        require(isPaused);
        _;
    }
    function setAdmin(address _newAdmin) external onlyAdmin {
        require(_newAdmin != address(0));
        emit AdminTransferred(addrAdmin, _newAdmin);
        addrAdmin = _newAdmin;
    }
    function doPause() external onlyAdmin whenNotPaused {
        isPaused = true;
    }
    function doUnpause() external onlyAdmin whenPaused {
        isPaused = false;
    }
}
