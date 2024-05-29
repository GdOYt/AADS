contract VestingMasterContract is Owned {
    using SafeMath for uint256;
    address public tokenAddress;
    bool public canReceiveTokens;
    address public moderator;
    uint256 public internalBalance;
    uint256 public amountLockedInVestings;
    bool public fallbackTriggered;
    struct VestingStruct {
        uint256 arrayPointer;
        address beneficiary;
        address releasingScheduleContract;
        string vestingType;
        uint256 vestingVersion;
    }
    address[] public vestingAddresses;
    mapping(address => VestingStruct) public addressToVestingStruct;
    mapping(address => address) public beneficiaryToVesting;
    event VestingContractFunded(address beneficiary, address tokenAddress, uint256 amount);
    event LockedAmountDecreased(uint256 amount);
    event LockedAmountIncreased(uint256 amount);
    event TokensReceivedSinceLastCheck(uint256 amount);
    event TokensReceivedWithApproval(uint256 amount, bytes extraData);
    event NotAllowedTokensReceived(uint256 amount);
    function VestingMasterContract(address _tokenAddress, bool _canReceiveTokens) public{
        tokenAddress = _tokenAddress;
        canReceiveTokens = _canReceiveTokens;
        internalBalance = 0;
        amountLockedInVestings = 0;
    }
    function vestingExists(address _vestingAddress) public view returns (bool exists){
        if (vestingAddresses.length == 0) {return false;}
        return (vestingAddresses[addressToVestingStruct[_vestingAddress].arrayPointer] == _vestingAddress);
    }
    function storeNewVesting(address _vestingAddress, address _beneficiary, address _releasingScheduleContract, string _vestingType, uint256 _vestingVersion) internal onlyOwner returns (uint256 vestingsLength) {
        require(!vestingExists(_vestingAddress));
        addressToVestingStruct[_vestingAddress].beneficiary = _beneficiary;
        addressToVestingStruct[_vestingAddress].releasingScheduleContract = _releasingScheduleContract;
        addressToVestingStruct[_vestingAddress].vestingType = _vestingType;
        addressToVestingStruct[_vestingAddress].vestingVersion = _vestingVersion;
        beneficiaryToVesting[_beneficiary] = _vestingAddress;
        addressToVestingStruct[_vestingAddress].arrayPointer = vestingAddresses.push(_vestingAddress) - 1;
        return vestingAddresses.length;
    }
    function deleteVestingFromStorage(address _vestingAddress) internal onlyOwner returns (uint256 vestingsLength) {
        require(vestingExists(_vestingAddress));
        delete (beneficiaryToVesting[addressToVestingStruct[_vestingAddress].beneficiary]);
        uint256 indexToDelete = addressToVestingStruct[_vestingAddress].arrayPointer;
        address keyToMove = vestingAddresses[vestingAddresses.length - 1];
        vestingAddresses[indexToDelete] = keyToMove;
        addressToVestingStruct[keyToMove].arrayPointer = indexToDelete;
        vestingAddresses.length--;
        return vestingAddresses.length;
    }
    function addVesting(address _vestingAddress, address _beneficiary, address _releasingScheduleContract, string _vestingType, uint256 _vestingVersion) public {
        uint256 vestingBalance = TokenVestingInterface(_vestingAddress).getTokenBalance();
        amountLockedInVestings = amountLockedInVestings.add(vestingBalance);
        storeNewVesting(_vestingAddress, _beneficiary, _releasingScheduleContract, _vestingType, _vestingVersion);
    }
    function releaseVesting(address _vestingContract) external {
        require(vestingExists(_vestingContract));
        require(msg.sender == addressToVestingStruct[_vestingContract].beneficiary || msg.sender == owner || msg.sender == moderator);
        TokenVestingInterface(_vestingContract).release();
    }
    function releaseMyTokens() external {
        address vesting = beneficiaryToVesting[msg.sender];
        require(vesting != 0);
        TokenVestingInterface(vesting).release();
    }
    function fundVesting(address _vestingContract, uint256 _amount) public onlyOwner {
        checkForReceivedTokens();
        require((internalBalance >= _amount) && (getTokenBalance() >= _amount));
        require(vestingExists(_vestingContract));
        internalBalance = internalBalance.sub(_amount);
        ERC20TokenInterface(tokenAddress).transfer(_vestingContract, _amount);
        TokenVestingInterface(_vestingContract).updateBalanceOnFunding(_amount);
        emit VestingContractFunded(_vestingContract, tokenAddress, _amount);
    }
    function getTokenBalance() public constant returns (uint256) {
        return ERC20TokenInterface(tokenAddress).balanceOf(address(this));
    }
    function revokeVesting(address _vestingContract, string _reason) external onlyOwner {
        TokenVestingInterface subVestingContract = TokenVestingInterface(_vestingContract);
        subVestingContract.revoke(_reason);
        deleteVestingFromStorage(_vestingContract);
    }
    function addInternalBalance(uint256 _amount) external {
        require(vestingExists(msg.sender));
        internalBalance = internalBalance.add(_amount);
    }
    function addLockedAmount(uint256 _amount) external {
        require(vestingExists(msg.sender));
        amountLockedInVestings = amountLockedInVestings.add(_amount);
        emit LockedAmountIncreased(_amount);
    }
    function substractLockedAmount(uint256 _amount) external {
        require(vestingExists(msg.sender));
        amountLockedInVestings = amountLockedInVestings.sub(_amount);
        emit LockedAmountDecreased(_amount);
    }
    function checkForReceivedTokens() public {
        if (getTokenBalance() != internalBalance) {
            uint256 receivedFunds = getTokenBalance().sub(internalBalance);
            if (canReceiveTokens) {
                amountLockedInVestings = amountLockedInVestings.add(receivedFunds);
                internalBalance = getTokenBalance();
            }
            else {
                emit NotAllowedTokensReceived(receivedFunds);
            }
            emit TokensReceivedSinceLastCheck(receivedFunds);
        } else {
            emit TokensReceivedSinceLastCheck(0);
        }
        fallbackTriggered = false;
    }
    function salvageNotAllowedTokensSentToContract(address _contractFrom, address _to, uint _amount) external onlyOwner {
        if (_contractFrom == address(this)) {
            checkForReceivedTokens();
            require(_amount <= getTokenBalance() - internalBalance);
            ERC20TokenInterface(tokenAddress).transfer(_to, _amount);
        }
        if (vestingExists(_contractFrom)) {
            TokenVestingInterface(_contractFrom).salvageNotAllowedTokensSentToContract(_to, _amount);
        }
    }
    function salvageOtherTokensFromContract(address _tokenAddress, address _contractAddress, address _to, uint _amount) external onlyOwner {
        require(_tokenAddress != tokenAddress);
        if (_contractAddress == address(this)) {
            ERC20TokenInterface(_tokenAddress).transfer(_to, _amount);
        }
        if (vestingExists(_contractAddress)) {
            TokenVestingInterface(_contractAddress).salvageOtherTokensFromContract(_tokenAddress, _to, _amount);
        }
    }
    function killContract() external onlyOwner {
        require(vestingAddresses.length == 0);
        ERC20TokenInterface(tokenAddress).transfer(owner, getTokenBalance());
        selfdestruct(owner);
    }
    function setWithdrawalAddress(address _vestingContract, address _beneficiary) external {
        require(vestingExists(_vestingContract));
        TokenVestingContract vesting = TokenVestingContract(_vestingContract);
        require(msg.sender == vesting.beneficiary() || (msg.sender == owner && vesting.changable()));
        TokenVestingInterface(_vestingContract).setWithdrawalAddress(_beneficiary);
        addressToVestingStruct[_vestingContract].beneficiary = _beneficiary;
    }
    function receiveApproval(address _from, uint256 _amount, address _tokenAddress, bytes _extraData) external {
        require(canReceiveTokens);
        require(_tokenAddress == tokenAddress);
        ERC20TokenInterface(_tokenAddress).transferFrom(_from, address(this), _amount);
        amountLockedInVestings = amountLockedInVestings.add(_amount);
        internalBalance = internalBalance.add(_amount);
        emit TokensReceivedWithApproval(_amount, _extraData);
    }
    function deployVesting(
        address _beneficiary,
        string _vestingType,
        uint256 _vestingVersion,
        bool _canReceiveTokens,
        bool _revocable,
        bool _changable,
        address _releasingSchedule
    ) public onlyOwner {
        TokenVestingContract newVesting = new TokenVestingContract(_beneficiary, tokenAddress, _canReceiveTokens, _revocable, _changable, _releasingSchedule);
        addVesting(newVesting, _beneficiary, _releasingSchedule, _vestingType, _vestingVersion);
    }
    function deployOtherVesting(
        address _beneficiary,
        uint256 _amount,
        uint256 _startTime
    ) public onlyOwner {
        TgeOtherReleasingScheduleContract releasingSchedule = new TgeOtherReleasingScheduleContract(_amount, _startTime);
        TokenVestingContract newVesting = new TokenVestingContract(_beneficiary, tokenAddress, true, true, true, releasingSchedule);
        addVesting(newVesting, _beneficiary, releasingSchedule, 'other', 1);
        fundVesting(newVesting, _amount);
    }
    function deployTgeTeamVesting(
    address _beneficiary,
    uint256 _amount
    ) public onlyOwner {
        TgeTeamReleasingScheduleContract releasingSchedule = new TgeTeamReleasingScheduleContract();
        TokenVestingContract newVesting = new TokenVestingContract(_beneficiary, tokenAddress, true, true, true, releasingSchedule);
        addVesting(newVesting, _beneficiary, releasingSchedule, 'X8 team', 1);
        fundVesting(newVesting, _amount);
    }
    function acceptOwnershipOfVesting(address _vesting) external onlyOwner {
        TokenVestingContract(_vesting).acceptOwnership();
    }
    function setModerator(address _moderator) external onlyOwner {
        moderator = _moderator;
    }
    function () external{
        fallbackTriggered = true;
    }
}
