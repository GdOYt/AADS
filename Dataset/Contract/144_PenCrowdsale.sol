contract PenCrowdsale is Pausable {
    using SafeMath for uint256;
    Pen public token;
    uint256 public startTime;
    uint256 public endTime;
    address public beneficiary;
    uint256 public rate;
    uint256 public weiRaised;
    uint256 public capReleaseTimestamp;
    uint256 public extraTime;
    mapping(address => bool) public whitelists;
    mapping(address => uint256) public contributions;
    uint256 public constant FUNDING_ETH_HARD_CAP = 15000 * 1 ether;
    uint256 public minContribution = 50**16;
    uint256 public maxContribution = 100**18;
    uint256 public remainCap;
    Stages public stage;
    enum Stages { 
        Setup,
        OfferingStarted,
        OfferingEnded
    }
    event OfferingOpens(uint256 startTime, uint256 endTime);
    event OfferingCloses(uint256 endTime, uint256 totalWeiRaised);
    event TokenPurchase(address indexed purchaser, uint256 value, uint256 amount);
    modifier atStage(Stages expectedStage) {
        require(stage == expectedStage);
        _;
    }
    function PenCrowdsale(
        uint256 testToEtherRate, 
        address beneficiaryAddr, 
        address tokenAddress
    ) public {
        require(testToEtherRate > 0);
        require(beneficiaryAddr != address(0));
        require(tokenAddress != address(0));
        token = Pen(tokenAddress);
        rate = testToEtherRate;
        beneficiary = beneficiaryAddr;
        stage = Stages.Setup;
    }
    function () public payable {
        buy();
    }
    function ownerSafeWithdrawal() external onlyOwner {
        beneficiary.transfer(this.balance);
    }
    function updateRate(uint256 bouToEtherRate) public onlyOwner atStage(Stages.Setup) {
        rate = bouToEtherRate;
    }
    function whitelist(address[] users) public onlyOwner {
        for (uint32 i = 0; i < users.length; i++) {
            whitelists[users[i]] = true;
        }
    }
    function whitelistRemove(address user) public onlyOwner{
      require(whitelists[user]);
      whitelists[user] = false;
    }
    function startOffering(uint256 durationInSeconds) public onlyOwner atStage(Stages.Setup) {
        stage = Stages.OfferingStarted;
        startTime = now;
        capReleaseTimestamp = startTime + 5 hours;
        extraTime = capReleaseTimestamp + 7 days;
        endTime = extraTime.add(durationInSeconds);
        OfferingOpens(startTime, endTime);
    }
    function endOffering() public onlyOwner atStage(Stages.OfferingStarted) {
        endOfferingImpl();
    }
    function buy() public payable whenNotPaused atStage(Stages.OfferingStarted) returns (bool) {
        if (whitelists[msg.sender]) {
              buyTokens();
              return true;
        }
        revert();
    }
    function hasEnded() public view returns (bool) {
        return now > endTime || stage == Stages.OfferingEnded;
    }
    modifier validPurchase() {
        require(now >= startTime && now <= endTime && stage == Stages.OfferingStarted);
        if(now > capReleaseTimestamp) {
          maxContribution = 5000 * 1 ether;
        }
        uint256 contributionInWei = msg.value;
        address participant = msg.sender; 
        require(contributionInWei <= maxContribution.sub(contributions[participant]));
        require(participant != address(0) && contributionInWei >= minContribution && contributionInWei <= maxContribution);
        require(weiRaised.add(contributionInWei) <= FUNDING_ETH_HARD_CAP);
        _;
    }
    function buyTokens() internal validPurchase {
        uint256 contributionInWei = msg.value;
        address participant = msg.sender;
        uint256 tokens = contributionInWei.mul(rate);
        if (!token.transferFrom(token.owner(), participant, tokens)) {
            revert();
        }
        weiRaised = weiRaised.add(contributionInWei);
        contributions[participant] = contributions[participant].add(contributionInWei);
        remainCap = FUNDING_ETH_HARD_CAP.sub(weiRaised);
        if (weiRaised >= FUNDING_ETH_HARD_CAP) {
            endOfferingImpl();
        }
        beneficiary.transfer(contributionInWei);
        TokenPurchase(msg.sender, contributionInWei, tokens);       
    }
    function endOfferingImpl() internal {
        endTime = now;
        stage = Stages.OfferingEnded;
        OfferingCloses(endTime, weiRaised);
    }
    function allocateTokensBeforeOffering(address to, uint256 tokens) public onlyOwner atStage(Stages.Setup) returns (bool) {
        if (!token.transferFrom(token.owner(), to, tokens)) {
            revert();
        }
        return true;
    }
    function batchAllocateTokensBeforeOffering(address[] toList, uint256[] tokensList) external onlyOwner  atStage(Stages.Setup)  returns (bool)  {
        require(toList.length == tokensList.length);
        for (uint32 i = 0; i < toList.length; i++) {
            allocateTokensBeforeOffering(toList[i], tokensList[i]);
        }
        return true;
    }
}
