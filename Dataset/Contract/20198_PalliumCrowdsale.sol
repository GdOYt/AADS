contract PalliumCrowdsale is StagedCrowdsale, MintedCrowdsale, Pausable {
    StagedRefundVault public vault;
    function PalliumCrowdsale(uint256 _rate, address _wallet) public
        Crowdsale(_rate, _wallet, new PalliumToken())
        StagedCrowdsale(){  
            _processPurchase(_wallet, 25*(10**24));
            vault = new StagedRefundVault(_wallet);
            stages[0] = Stage(0, 5*(10**24), 33*(10**23), 0, 100, 1522540800, 1525132800);
            stages[1] = Stage(1, 375*(10**23), 2475*(10**22),  0, 50, 1533081600, 1535760000);
            stages[2] = Stage(2, 75*(10**24), 495*(10**23), 0, 25, 1543622400, 1546300800);
            stages[3] = Stage(3, 1075*(10**23), 7095*(10**22), 0, 15, 1554076800, 1556668800);
    }   
    function goalReached() internal view returns (bool) {
        return stages[currentStage].currentMinted >= stages[currentStage].softCap;
    }
    function hardCapReached() internal view returns (bool) {
        return stages[currentStage].currentMinted >= stages[currentStage].hardCap;
    }
    function claimRefund() public {
      require(!goalReached());
      require(currentState == State.Running);
      vault.refund(msg.sender);
    }
    function toggleVaultStateToAcive() public onlyOwner {
        require(now >= stages[currentStage].startTime - 1 days);
        vault.activate();
    }
    function finalizeCurrentStage() public onlyOwner {
        require(now > stages[currentStage].endTime || hardCapReached());
        require(currentState == State.Running);
        if (goalReached()) {
            vault.stageClose();
        } else {
            vault.enableRefunds();
        }
        if (stages[currentStage].index < 3) {
            setStage(currentStage + 1);
        } else
        {
            finalizationCrowdsale();
        }
    }
    function finalizationCrowdsale() internal {
        vault.close();
        setState(StagedCrowdsale.State.Finished);
        PalliumToken(token).finishMinting();
        PalliumToken(token).transferOwnership(owner);
    } 
    function migrateCrowdsale(address _newOwner) public onlyOwner {
        require(currentState == State.Paused);
        PalliumToken(token).transferOwnership(_newOwner);
        StagedRefundVault(vault).transferOwnership(_newOwner);
    }
    function setState(State _nextState) public onlyOwner {
        bool canToggleState
            =  (currentState == State.Created && _nextState == State.Running)
            || (currentState == State.Running && _nextState == State.Paused)
            || (currentState == State.Paused  && _nextState == State.Running)
            || (currentState == State.Running && _nextState == State.Finished);
        require(canToggleState);
        currentState = _nextState;
    }
    function manualPurchaseTokens (address _beneficiary, uint256 _weiAmount) public onlyOwner {
        _preValidatePurchase(_beneficiary, _weiAmount);
        uint256 tokens = _getTokenAmount(_weiAmount);
        _processPurchase(_beneficiary, tokens);
        TokenPurchase(msg.sender, _beneficiary, _weiAmount, tokens);
        _updatePurchasingState(_beneficiary, _weiAmount);
    }
    function _forwardFunds() internal {
        vault.deposit.value(this.balance)(msg.sender);
    }
}
