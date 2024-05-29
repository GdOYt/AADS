contract StageCrowdsale is FinalizableCrowdsale {
    bool public previousStageIsFinalized = false;
    StageCrowdsale public previousStage;
    constructor(
        uint256 _rate,
        address _wallet,
        ERC20 _token,
        uint256 _openingTime,
        uint256 _closingTime,
        StageCrowdsale _previousStage
    )
        public
        Crowdsale(_rate, _wallet, _token)
        TimedCrowdsale(_openingTime, _closingTime)
    {
        previousStage = _previousStage;
        if (_previousStage == address(0)) {
            previousStageIsFinalized = true;
        }
    }
    modifier isNotFinalized() {
        require(!isFinalized, "Call on finalized.");
        _;
    }
    modifier previousIsFinalized() {
        require(isPreviousStageFinalized(), "Call on previous stage finalized.");
        _;
    }
    function finalizeStage() public onlyOwner isNotFinalized {
        _finalizeStage();
    }
    function proxyBuyTokens(address _beneficiary) public payable {
        uint256 weiAmount = msg.value;
        _preValidatePurchase(_beneficiary, weiAmount);
        uint256 tokens = _getTokenAmount(weiAmount);
        weiRaised = weiRaised.add(weiAmount);
        _processPurchase(_beneficiary, tokens);
        emit TokenPurchase(tx.origin, _beneficiary, weiAmount, tokens);
        _updatePurchasingState(_beneficiary, weiAmount);
        _forwardFunds();
        _postValidatePurchase(_beneficiary, weiAmount);
    }
    function isPreviousStageFinalized() public returns (bool) {
        if (previousStageIsFinalized) {
            return true;
        }
        if (previousStage.isFinalized()) {
            previousStageIsFinalized = true;
        }
        return previousStageIsFinalized;
    }
    function _finalizeStage() internal isNotFinalized {
        finalization();
        emit Finalized();
        isFinalized = true;
    }
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal isNotFinalized previousIsFinalized {
        super._preValidatePurchase(_beneficiary, _weiAmount);
    }
}
