contract Controlled is Ownable{
    constructor() public {
        setExclude(msg.sender);
    }
    bool public transferEnabled = false;
    bool public plockFlag=true;
    mapping(address => bool) locked;
    mapping(address => bool) exclude;
    function enableTransfer(bool _enable) public onlyOwner{
        transferEnabled = _enable;
    }
    function enableLockFlag(bool _enable) public onlyOwner returns (bool success){
        plockFlag = _enable;
        return true;
    }
    function addLock(address _addr) public onlyOwner returns (bool success){
        require(_addr!=msg.sender);
        locked[_addr] = true;
        return true;
    }
    function setExclude(address _addr) public onlyOwner returns (bool success){
        exclude[_addr] = true;
        return true;
    }
    function removeLock(address _addr) public onlyOwner returns (bool success){
        locked[_addr] = false;
        return true;
    }
    modifier transferAllowed(address _addr) {
        if (!exclude[_addr]) {
            assert(transferEnabled);
            if(plockFlag){
                assert(!locked[_addr]);
            }
        }
        _;
    }
}
