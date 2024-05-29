contract HWCIntegration is BaseGameLogic {
    event NewHWCRegister(address owner, string aD, string aW);
    constructor(string _name, string _symbol) BaseGameLogic(_name, _symbol) public {}
    struct HWCInfo {
        string aDeposit;
        string aWithdraw;
        uint deposit;
        uint index1;         
    }
    uint public cHWCtoEth = 0;
    uint256 public prizeFundHWC = 0;
    mapping (address => HWCInfo) hwcAddress;
    address[] hwcAddressList;
    function _addToFundHWC(uint256 _val) internal whenNotPaused {
        prizeFundHWC = prizeFundHWC.add(_val.mul(prizeFundFactor).div(10000));
    }
    function registerHWCDep(string _a) public {
        require(bytes(_a).length == 34);
        hwcAddress[msg.sender].aDeposit = _a;
        if(hwcAddress[msg.sender].index1 == 0){
            hwcAddress[msg.sender].index1 = hwcAddressList.push(msg.sender);
        }
        emit NewHWCRegister(msg.sender, _a, '');
    }
    function registerHWCWit(string _a) public {
        require(bytes(_a).length == 34);
        hwcAddress[msg.sender].aWithdraw = _a;
        if(hwcAddress[msg.sender].index1 == 0){
            hwcAddress[msg.sender].index1 = hwcAddressList.push(msg.sender);
        }
        emit NewHWCRegister(msg.sender, '', _a);
    }
    function getHWCAddressCount() public view returns (uint){
        return hwcAddressList.length;
    }
    function getHWCAddressByIndex(uint _index) public view returns (string aDeposit, string aWithdraw, uint d) {
        require(_index < hwcAddressList.length);
        return getHWCAddress(hwcAddressList[_index]);
    }
    function getHWCAddress(address _val) public view returns (string aDeposit, string aWithdraw, uint d) {
        aDeposit = hwcAddress[_val].aDeposit;
        aWithdraw = hwcAddress[_val].aWithdraw;
        d = hwcAddress[_val].deposit;
    }
    function setHWCDeposit(address _user, uint _val) external onlyAdmin {
        hwcAddress[_user].deposit = _val;
    }
    function createTokenByHWC(address _userTo, uint256 _parentId) external onlyAdmin whenNotPaused returns (uint) {
        uint256 tokenPrice = basePrice.div(1e10).mul(cHWCtoEth);
        if(_parentId > 0) {
            tokenPrice = calculateTokenPrice(_parentId);
            tokenPrice = tokenPrice.div(1e10).mul(cHWCtoEth);
            uint gameFee = tokenPrice.mul(gameCloneFee).div(10000);
            _addToFundHWC(gameFee);
            uint256 ownerProceed = tokenPrice.sub(gameFee);
            address tokenOwnerAddress = tokenOwner[_parentId];
            hwcAddress[tokenOwnerAddress].deposit = hwcAddress[tokenOwnerAddress].deposit + ownerProceed;
        } else {
            _addToFundHWC(tokenPrice);
        }
        return _createToken(_parentId, _userTo);
    }
    function setCourse(uint _val) external onlyAdmin {
        cHWCtoEth = _val;
    }
}
