contract MultiStageCrowdsale is Ownable {
    uint256 public currentStageIndex = 0;
    StageCrowdsale[] public stages;
    event StageAdded();
    function () external payable {
        buyTokens(msg.sender);
    }
    modifier hasCurrentStage() {
        require(currentStageIndex < stages.length);
        _;
    }
    modifier validBuyCall(address _beneficiary) {
        require(_beneficiary != address(0));
        require(msg.value != 0);
        _;
    }
    function addStageCrowdsale(address _stageCrowdsaleAddress) public onlyOwner {
        require(_stageCrowdsaleAddress != address(0));
        StageCrowdsale stageToBeAdded = StageCrowdsale(_stageCrowdsaleAddress);
        if (stages.length > 0) {
            require(stageToBeAdded.previousStage() != address(0));
            StageCrowdsale lastStage = stages[stages.length - 1];
            require(stageToBeAdded.openingTime() >= lastStage.closingTime());
        }
        stages.push(stageToBeAdded);
        emit StageAdded();
    }
    function buyTokens(address _beneficiary) public payable validBuyCall(_beneficiary) hasCurrentStage {
        StageCrowdsale stage = updateCurrentStage();
        stage.proxyBuyTokens.value(msg.value)(_beneficiary);
        updateCurrentStage();
    }
    function getCurrentStage() public view returns (StageCrowdsale) {
        if (stages.length > 0) {
            return stages[currentStageIndex];
        }
    }
    function updateCurrentStage() public returns (StageCrowdsale currentStage) {
        if (currentStageIndex < stages.length) {
            currentStage = stages[currentStageIndex];
            while (currentStage.isFinalized() && currentStageIndex + 1 < stages.length) {
                currentStage = stages[++currentStageIndex];
            }
        }
    }
}
