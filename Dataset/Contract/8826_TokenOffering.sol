contract TokenOffering is StandardToken, Ownable, BurnableToken {
    bool public offeringEnabled;
    uint256 public currentTotalTokenOffering;
    uint256 public currentTokenOfferingRaised;
    uint256 public bonusRateOneEth;
    uint256 public startTime;
    uint256 public endTime;
    bool public isBurnInClose = false;
    bool public isOfferingStarted = false;
    event OfferingOpens(uint256 startTime, uint256 endTime, uint256 totalTokenOffering, uint256 bonusRateOneEth);
    event OfferingCloses(uint256 endTime, uint256 tokenOfferingRaised);
    function setBonusRate(uint256 _bonusRateOneEth) public onlyOwner {
        bonusRateOneEth = _bonusRateOneEth;
    }
    function preValidatePurchase(uint256 _amount) internal {
        require(_amount > 0);
        require(isOfferingStarted);
        require(offeringEnabled);
        require(currentTokenOfferingRaised.add(_amount) <= currentTotalTokenOffering);
        require(block.timestamp >= startTime && block.timestamp <= endTime);
    }
    function stopOffering() public onlyOwner {
        offeringEnabled = false;
    }
    function resumeOffering() public onlyOwner {
        offeringEnabled = true;
    }
    function startOffering(
        uint256 _tokenOffering, 
        uint256 _bonusRateOneEth, 
        uint256 _startTime, 
        uint256 _endTime,
        bool _isBurnInClose
    ) public onlyOwner returns (bool) {
        require(_tokenOffering <= balances[owner]);
        require(_startTime <= _endTime);
        require(_startTime >= block.timestamp);
        require(!isOfferingStarted);
        isOfferingStarted = true;
        startTime = _startTime;
        endTime = _endTime;
        isBurnInClose = _isBurnInClose;
        currentTokenOfferingRaised = 0;
        currentTotalTokenOffering = _tokenOffering;
        offeringEnabled = true;
        setBonusRate(_bonusRateOneEth);
        emit OfferingOpens(startTime, endTime, currentTotalTokenOffering, bonusRateOneEth);
        return true;
    }
    function updateStartTime(uint256 _startTime) public onlyOwner {
        require(isOfferingStarted);
        require(_startTime <= endTime);
        require(_startTime >= block.timestamp);
        startTime = _startTime;
    }
    function updateEndTime(uint256 _endTime) public onlyOwner {
        require(isOfferingStarted);
        require(_endTime >= startTime);
        endTime = _endTime;
    }
    function updateBurnableStatus(bool _isBurnInClose) public onlyOwner {
        require(isOfferingStarted);
        isBurnInClose = _isBurnInClose;
    }
    function endOffering() public onlyOwner {
        if (isBurnInClose) {
            burnRemainTokenOffering();
        }
        emit OfferingCloses(endTime, currentTokenOfferingRaised);
        resetOfferingStatus();
    }
    function burnRemainTokenOffering() internal {
        if (currentTokenOfferingRaised < currentTotalTokenOffering) {
            uint256 remainTokenOffering = currentTotalTokenOffering.sub(currentTokenOfferingRaised);
            _burn(owner, remainTokenOffering);
        }
    }
    function resetOfferingStatus() internal {
        isOfferingStarted = false;        
        startTime = 0;
        endTime = 0;
        currentTotalTokenOffering = 0;
        currentTokenOfferingRaised = 0;
        bonusRateOneEth = 0;
        offeringEnabled = false;
        isBurnInClose = false;
    }
}
