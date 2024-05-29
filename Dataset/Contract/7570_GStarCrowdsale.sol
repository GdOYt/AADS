contract GStarCrowdsale is WhitelistedCrowdsale {
    using SafeMath for uint256;
    uint256 constant public presaleStartTime = 1531051200;  
    uint256 constant public startTime = 1532260800;  
    uint256 constant public endTime = 1534593600;  
    mapping (address => uint256) public depositedTokens;
    uint256 constant public MINIMUM_PRESALE_PURCHASE_AMOUNT_IN_WEI = 1 ether;
    uint256 constant public MINIMUM_PURCHASE_AMOUNT_IN_WEI = 0.1 ether;
    uint256 public tokensWeiRaised = 0;
    uint256 constant public fundingGoal = 76000 ether;
    uint256 constant public presaleFundingGoal = 1000 ether;
    bool public fundingGoalReached = false;
    bool public presaleFundingGoalReached = false;
    uint256 public privateContribution = 0;
    bool public crowdsaleActive = false;
    bool public isCrowdsaleClosed = false;
    uint256 public tokensReleasedAmount = 0;
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
    event GoalReached(uint256 totalEtherAmountRaised);
    event PresaleGoalReached(uint256 totalEtherAmountRaised);
    event StartCrowdsale();
    event StopCrowdsale();
    event ReleaseTokens(address[] _beneficiaries);
    event Close();
    function GStarCrowdsale (
        uint256 _rate,
        address _wallet,
        GStarToken token
        ) public Crowdsale(_rate, _wallet, token) {
    }
    function buyTokens(address _beneficiary) public payable {
        uint256 weiAmount = msg.value;
        _preValidatePurchase(_beneficiary, weiAmount);
        uint256 tokens = _getTokenAmount(weiAmount);
        weiRaised = weiRaised.add(weiAmount);
        emit TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens);
        _updatePurchasingState(_beneficiary, weiAmount);
        _forwardFunds();
        _processPurchase(_beneficiary, weiAmount);
    }
    function getRate() public view returns (uint256) {
        if (block.timestamp <= startTime) { return ((rate / 100) * 120); }  
        if (block.timestamp <= startTime.add(1 days)) {return ((rate / 100) * 108);}  
        return rate;
    }
    function changePrivateContribution(uint256 etherWeiAmount) external onlyOwner {
        privateContribution = etherWeiAmount;
    }
    function startCrowdsale() external onlyOwner {
        require(!crowdsaleActive);
        require(!isCrowdsaleClosed);
        crowdsaleActive = true;
        emit StartCrowdsale();
    }
    function stopCrowdsale() external onlyOwner {
        require(crowdsaleActive);
        crowdsaleActive = false;
        emit StopCrowdsale();
    }
    function releaseTokens(address[] contributors) external onlyOwner {
        for (uint256 j = 0; j < contributors.length; j++) {
            uint256 tokensAmount = depositedTokens[contributors[j]];
            if (tokensAmount > 0) {
                super._deliverTokens(contributors[j], tokensAmount);
                depositedTokens[contributors[j]] = 0;
                tokensReleasedAmount = tokensReleasedAmount.add(tokensAmount);
            }
        }
    }
    function close() external onlyOwner {
        crowdsaleActive = false;
        isCrowdsaleClosed = true;
        token.transfer(owner, token.balanceOf(address(this)));
        emit Close();
    }
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
        bool withinPeriod = now >= presaleStartTime && now <= endTime;
        bool atLeastMinimumAmount = false;
        if(block.timestamp <= startTime) {
            require(_weiAmount.add(weiRaised.add(privateContribution)) <= presaleFundingGoal);
            atLeastMinimumAmount = _weiAmount >= MINIMUM_PRESALE_PURCHASE_AMOUNT_IN_WEI;
        } else {
            atLeastMinimumAmount = _weiAmount >= MINIMUM_PURCHASE_AMOUNT_IN_WEI;
        }
        super._preValidatePurchase(_beneficiary, _weiAmount);
        require(msg.sender == _beneficiary);
        require(_weiAmount.add(weiRaised.add(privateContribution)) <= fundingGoal);
        require(withinPeriod);
        require(atLeastMinimumAmount);
        require(crowdsaleActive);
    }
    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
        return _weiAmount.mul(getRate());
    }
    function _updatePurchasingState(address _beneficiary, uint256 _weiAmount) internal {
        tokensWeiRaised = tokensWeiRaised.add(_getTokenAmount(_weiAmount));
        _updateFundingGoal();
    }
    function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
        depositedTokens[_beneficiary] = depositedTokens[_beneficiary].add(_getTokenAmount(_tokenAmount));
    }
    function _updateFundingGoal() internal {
        if (weiRaised.add(privateContribution) >= fundingGoal) {
            fundingGoalReached = true;
            emit GoalReached(weiRaised.add(privateContribution));
        }
        if(block.timestamp <= startTime) {
            if(weiRaised.add(privateContribution) >= presaleFundingGoal) {
                presaleFundingGoalReached = true;
                emit PresaleGoalReached(weiRaised.add(privateContribution));
            }
        }
    }
}
