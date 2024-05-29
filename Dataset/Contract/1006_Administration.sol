contract Administration {
    event AdminTransferred(address indexed _from, address indexed _to);
    event Pause();
    event Unpause();
    address public adminAddress = 0xbd74Dec00Af1E745A21d5130928CD610BE963027;
    bool public paused = false;
    modifier onlyAdmin() {
        require(msg.sender == adminAddress);
        _;
    }
    function setAdmin(address _newAdmin) public onlyAdmin {
        require(_newAdmin != address(0));
        AdminTransferred(adminAddress, _newAdmin);
        adminAddress = _newAdmin;
    }
    function withdrawBalance() external onlyAdmin {
        adminAddress.transfer(this.balance);
    }
    modifier whenNotPaused() {
        require(!paused);
        _;
    }
    modifier whenPaused() {
        require(paused);
        _;
    }
    function pause() public onlyAdmin whenNotPaused returns(bool) {
        paused = true;
        Pause();
        return true;
    }
    function unpause() public onlyAdmin whenPaused returns(bool) {
        paused = false;
        Unpause();
        return true;
    }
    uint oneEth = 1 ether;
}
