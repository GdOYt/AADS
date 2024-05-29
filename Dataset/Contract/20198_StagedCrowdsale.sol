contract StagedCrowdsale is Crowdsale {
    struct Stage {
        uint    index;
        uint256 hardCap;
        uint256 softCap;
        uint256 currentMinted;
        uint256 bonusMultiplier;
        uint256 startTime;
        uint256 endTime;
    }
    mapping (uint => Stage) public stages;
    uint256 public currentStage;
    enum State { Created, Paused, Running, Finished }
    State public currentState = State.Created;
    function StagedCrowdsale() public {
        currentStage = 0;
    }
    function setStage(uint _nextStage) internal {
        currentStage = _nextStage;
    }
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
        require(currentState == State.Running);
        require((now >= stages[currentStage].startTime) && (now <= stages[currentStage].endTime));
        require(_beneficiary != address(0));
        require(_weiAmount >= 200 szabo);
    } 
    function computeTokensWithBonus(uint256 _weiAmount) public view returns(uint256) {
        uint256 tokenAmount = super._getTokenAmount(_weiAmount);
        uint256 bonusAmount = tokenAmount.mul(stages[currentStage].bonusMultiplier).div(100); 
        return tokenAmount.add(bonusAmount);
    }
    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
        uint256 tokenAmount = computeTokensWithBonus(_weiAmount);
        uint256 currentHardCap = stages[currentStage].hardCap;
        uint256 currentMinted = stages[currentStage].currentMinted;
        if (currentMinted.add(tokenAmount) > currentHardCap) {
            return currentHardCap.sub(currentMinted);
        } 
        return tokenAmount;
    } 
    function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
        require(_tokenAmount > 0);
        super._processPurchase(_beneficiary, _tokenAmount);
        uint256 surrender = computeTokensWithBonus(msg.value) - _tokenAmount;
        if (msg.value > 0 && surrender > 0)
        {   
            uint256 currentRate = computeTokensWithBonus(msg.value) / msg.value;
            uint256 surrenderEth = surrender.div(currentRate);
            _beneficiary.transfer(surrenderEth);
        }
    }
    function _getTokenRaised(uint256 _weiAmount) internal view returns (uint256) {
        return stages[currentStage].currentMinted.add(_getTokenAmount(_weiAmount));
    }
    function _updatePurchasingState(address, uint256 _weiAmount) internal {
        stages[currentStage].currentMinted = stages[currentStage].currentMinted.add(computeTokensWithBonus(_weiAmount));
    }
}
