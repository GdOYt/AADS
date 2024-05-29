contract AccessControl is SafeMath{
    event ContractUpgrade(address newContract);
    address public ceoAddress;
    address public cfoAddress;
    address public cooAddress;
    address newContractAddress;
    uint public tip_total = 0;
    uint public tip_rate = 20000000000000000;
    bool public paused = false;
    modifier onlyCEO() {
        require(msg.sender == ceoAddress);
        _;
    }
    modifier onlyCFO() {
        require(msg.sender == cfoAddress);
        _;
    }
    modifier onlyCOO() {
        require(msg.sender == cooAddress);
        _;
    }
    modifier onlyCLevel() {
        require(
            msg.sender == cooAddress ||
            msg.sender == ceoAddress ||
            msg.sender == cfoAddress
        );
        _;
    }
    function () public payable{
        tip_total = safeAdd(tip_total, msg.value);
    }
    function amountWithTip(uint amount) internal returns(uint){
        uint tip = safeMul(amount, tip_rate) / (1 ether);
        tip_total = safeAdd(tip_total, tip);
        return safeSub(amount, tip);
    }
    function withdrawTip(uint amount) external onlyCFO {
        require(amount > 0 && amount <= tip_total);
        require(msg.sender.send(amount));
        tip_total = tip_total - amount;
    }
    function setNewAddress(address newContract) external onlyCEO whenPaused {
        newContractAddress = newContract;
        emit ContractUpgrade(newContract);
    }
    function setCEO(address _newCEO) external onlyCEO {
        require(_newCEO != address(0));
        ceoAddress = _newCEO;
    }
    function setCFO(address _newCFO) external onlyCEO {
        require(_newCFO != address(0));
        cfoAddress = _newCFO;
    }
    function setCOO(address _newCOO) external onlyCEO {
        require(_newCOO != address(0));
        cooAddress = _newCOO;
    }
    modifier whenNotPaused() {
        require(!paused);
        _;
    }
    modifier whenPaused {
        require(paused);
        _;
    }
    function pause() external onlyCLevel whenNotPaused {
        paused = true;
    }
    function unpause() public onlyCEO whenPaused {
        paused = false;
    }
}
