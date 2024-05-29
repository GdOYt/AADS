contract TokenVestingContract is Owned {
    using SafeMath for uint256;
    address public beneficiary;
    address public tokenAddress;
    bool public canReceiveTokens;
    bool public revocable;   
    bool public changable;   
    address public releasingScheduleContract;
    bool fallbackTriggered;
    bool public revoked;
    uint256 public alreadyReleasedAmount;
    uint256 public internalBalance;
    event Released(uint256 _amount);
    event RevokedAndDestroyed(string _reason);
    event WithdrawalAddressSet(address _newAddress);
    event TokensReceivedSinceLastCheck(uint256 _amount);
    event VestingReceivedFunding(uint256 _amount);
    event SetReleasingSchedule(address _addy);
    event NotAllowedTokensReceived(uint256 amount);
    function TokenVestingContract(address _beneficiary, address _tokenAddress, bool _canReceiveTokens, bool _revocable, bool _changable, address _releasingScheduleContract) public {
        beneficiary = _beneficiary;
        tokenAddress = _tokenAddress;
        canReceiveTokens = _canReceiveTokens;
        revocable = _revocable;
        changable = _changable;
        releasingScheduleContract = _releasingScheduleContract;
        alreadyReleasedAmount = 0;
        revoked = false;
        internalBalance = 0;
        fallbackTriggered = false;
    }
    function setReleasingSchedule(address _releasingScheduleContract) external onlyOwner {
        require(changable);
        releasingScheduleContract = _releasingScheduleContract;
        emit SetReleasingSchedule(releasingScheduleContract);
    }
    function setWithdrawalAddress(address _newAddress) external onlyOwner {
        beneficiary = _newAddress;
        emit WithdrawalAddressSet(_newAddress);
    }
    function release() external returns (uint256 transferedAmount) {
        checkForReceivedTokens();
        require(msg.sender == beneficiary || msg.sender == owner);
        uint256 amountToTransfer = ReleasingScheduleInterface(releasingScheduleContract).getReleasableFunds(this);
        require(amountToTransfer > 0);
        alreadyReleasedAmount = alreadyReleasedAmount.add(amountToTransfer);
        internalBalance = internalBalance.sub(amountToTransfer);
        VestingMasterInterface(owner).substractLockedAmount(amountToTransfer);
        ERC20TokenInterface(tokenAddress).transfer(beneficiary, amountToTransfer);
        emit Released(amountToTransfer);
        return amountToTransfer;
    }
    function revoke(string _reason) external onlyOwner {
        require(revocable);
        uint256 releasableFunds = ReleasingScheduleInterface(releasingScheduleContract).getReleasableFunds(this);
        ERC20TokenInterface(tokenAddress).transfer(beneficiary, releasableFunds);
        VestingMasterInterface(owner).substractLockedAmount(releasableFunds);
        VestingMasterInterface(owner).addInternalBalance(getTokenBalance());
        ERC20TokenInterface(tokenAddress).transfer(owner, getTokenBalance());
        emit RevokedAndDestroyed(_reason);
        selfdestruct(owner);
    }
    function getTokenBalance() public view returns (uint256 tokenBalance) {
        return ERC20TokenInterface(tokenAddress).balanceOf(address(this));
    }
    function updateBalanceOnFunding(uint256 _amount) external onlyOwner {
        internalBalance = internalBalance.add(_amount);
        emit VestingReceivedFunding(_amount);
    }
    function checkForReceivedTokens() public {
        if (getTokenBalance() != internalBalance) {
            uint256 receivedFunds = getTokenBalance().sub(internalBalance);
            if (canReceiveTokens) {
                internalBalance = getTokenBalance();
                VestingMasterInterface(owner).addLockedAmount(receivedFunds);
            } else {
                emit NotAllowedTokensReceived(receivedFunds);
            }
            emit TokensReceivedSinceLastCheck(receivedFunds);
        }
        fallbackTriggered = true;
    }
    function salvageOtherTokensFromContract(address _tokenAddress, address _to, uint _amount) external onlyOwner {
        require(_tokenAddress != tokenAddress);
        ERC20TokenInterface(_tokenAddress).transfer(_to, _amount);
    }
    function salvageNotAllowedTokensSentToContract(address _to, uint _amount) external onlyOwner {
        checkForReceivedTokens();
        require(_amount <= getTokenBalance() - internalBalance);
        ERC20TokenInterface(tokenAddress).transfer(_to, _amount);
    }
    function () external{
        fallbackTriggered = true;
    }
}
