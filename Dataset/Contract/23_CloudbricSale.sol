contract CloudbricSale is Pausable {
    using SafeMath for uint256;
    uint256 public startTime;
    uint256 public endTime;
    address private fundAddr;
    Cloudbric public token;
    uint256 public totalWeiRaised;
    uint256 public constant BASE_HARD_CAP_PER_ROUND = 20000 * 1 ether;
    uint256 public constant UINT256_MAX = ~uint256(0);
    uint256 public constant BASE_CLB_TO_ETH_RATE = 10000;
    uint256 public constant BASE_MIN_CONTRIBUTION = 0.1 * 1 ether;
    mapping(address => bool) public whitelist;
    mapping(address => mapping(uint8 => uint256)) public contPerRound;
    enum Stages {
        SetUp,
        Started,
        Ended
    }
    Stages public stage;
    enum SaleRounds {
        EarlyInvestment,
        PreSale1,
        PreSale2,
        CrowdSale
    }
    SaleRounds public round;
    struct RoundInfo {
        uint256 minContribution;
        uint256 maxContribution;
        uint256 hardCap;
        uint256 rate;
        uint256 weiRaised;
    }
    mapping(uint8 => RoundInfo) public roundInfos;
    struct AllocationInfo {
        bool isAllowed;
        uint256 allowedAmount;
    }
    mapping(address => AllocationInfo) private allocationList;
    event SaleStarted(uint256 startTime, uint256 endTime, SaleRounds round);
    event SaleEnded(uint256 endTime, uint256 totalWeiRaised, SaleRounds round);
    event TokenPurchase(address indexed purchaser, uint256 value, uint256 amount);
    modifier atStage(Stages expectedStage) {
        require(stage == expectedStage);
        _;
    }
    modifier atRound(SaleRounds expectedRound) {
        require(round == expectedRound);
        _;
    }
    modifier onlyValidPurchase() {
        require(round <= SaleRounds.CrowdSale);
        require(now >= startTime && now <= endTime);
        uint256 contributionInWei = msg.value;
        address purchaser = msg.sender;
        require(whitelist[purchaser]);
        require(purchaser != address(0));
        require(contributionInWei >= roundInfos[uint8(round)].minContribution);
        require(
            contPerRound[purchaser][uint8(round)].add(contributionInWei)
            <= roundInfos[uint8(round)].maxContribution
        );
        require(
            roundInfos[uint8(round)].weiRaised.add(contributionInWei)
            <= roundInfos[uint8(round)].hardCap
        );
        _;
    }
    function CloudbricSale(
        address fundAddress,
        address tokenAddress
    )
        public
    {
        require(fundAddress != address(0));
        require(tokenAddress != address(0));
        token = Cloudbric(tokenAddress);
        fundAddr = fundAddress;
        stage = Stages.Ended;
        round = SaleRounds.EarlyInvestment;
        uint8 roundIndex = uint8(round);
        roundInfos[roundIndex].minContribution = BASE_MIN_CONTRIBUTION;
        roundInfos[roundIndex].maxContribution = UINT256_MAX;
        roundInfos[roundIndex].hardCap = BASE_HARD_CAP_PER_ROUND;
        roundInfos[roundIndex].weiRaised = 0;
        roundInfos[roundIndex].rate = BASE_CLB_TO_ETH_RATE;
    }
    function () public payable {
        buy();
    }
    function withdraw() external onlyOwner {
        fundAddr.transfer(this.balance);
    }
    function addManyToWhitelist(address[] users) external onlyOwner {
        for (uint32 i = 0; i < users.length; i++) {
            addToWhitelist(users[i]);
        }
    }
    function addToWhitelist(address user) public onlyOwner {
        whitelist[user] = true;
    }
    function removeManyFromWhitelist(address[] users) external onlyOwner {
        for (uint32 i = 0; i < users.length; i++) {
            removeFromWhitelist(users[i]);
        }
    }
    function removeFromWhitelist(address user) public onlyOwner {
        whitelist[user] = false;
    }
    function setMinContributionForRound(
        SaleRounds _round,
        uint256 _minContribution
    )
        public
        onlyOwner
        atStage(Stages.SetUp)
    {
        require(round <= _round);
        roundInfos[uint8(_round)].minContribution =
            (_minContribution == 0) ? BASE_MIN_CONTRIBUTION : _minContribution;
    }
    function setMaxContributionForRound(
        SaleRounds _round,
        uint256 _maxContribution
    )
        public
        onlyOwner
        atStage(Stages.SetUp)
    {
        require(round <= _round);
        roundInfos[uint8(_round)].maxContribution =
            (_maxContribution == 0) ? UINT256_MAX : _maxContribution;
    }
    function setHardCapForRound(
        SaleRounds _round,
        uint256 _hardCap
    )
        public
        onlyOwner
        atStage(Stages.SetUp)
    {
        require(round <= _round);
        roundInfos[uint8(_round)].hardCap =
            (_hardCap == 0) ? BASE_HARD_CAP_PER_ROUND : _hardCap;
    }
    function setRateForRound(
        SaleRounds _round,
        uint256 _rate
    )
        public
        onlyOwner
        atStage(Stages.SetUp)
    {
        require(round <= _round);
        roundInfos[uint8(_round)].rate =
            (_rate == 0) ? BASE_CLB_TO_ETH_RATE : _rate;
    }
    function setUpSale(
        SaleRounds _round,
        uint256 _minContribution,
        uint256 _maxContribution,
        uint256 _hardCap,
        uint256 _rate
    )
        external
        onlyOwner
        atStage(Stages.Ended)
    {
        require(round <= _round);
        stage = Stages.SetUp;
        round = _round;
        setMinContributionForRound(_round, _minContribution);
        setMaxContributionForRound(_round, _maxContribution);
        setHardCapForRound(_round, _hardCap);
        setRateForRound(_round, _rate);
    }
    function startSale(uint256 durationInSeconds)
        external
        onlyOwner
        atStage(Stages.SetUp)
    {
        require(roundInfos[uint8(round)].minContribution > 0
            && roundInfos[uint8(round)].hardCap > 0);
        stage = Stages.Started;
        startTime = now;
        endTime = startTime.add(durationInSeconds);
        SaleStarted(startTime, endTime, round);
    }
    function endSale() external onlyOwner atStage(Stages.Started) {
        endTime = now;
        stage = Stages.Ended;
        SaleEnded(endTime, totalWeiRaised, round);
    }
    function buy()
        public
        payable
        whenNotPaused
        atStage(Stages.Started)
        onlyValidPurchase()
        returns (bool)
    {
        address purchaser = msg.sender;
        uint256 contributionInWei = msg.value;
        uint256 tokenAmount = contributionInWei.mul(roundInfos[uint8(round)].rate);
        if (!token.transferFrom(token.owner(), purchaser, tokenAmount)) {
            revert();
        }
        totalWeiRaised = totalWeiRaised.add(contributionInWei);
        roundInfos[uint8(round)].weiRaised =
            roundInfos[uint8(round)].weiRaised.add(contributionInWei);
        contPerRound[purchaser][uint8(round)] =
            contPerRound[purchaser][uint8(round)].add(contributionInWei);
        fundAddr.transfer(contributionInWei);
        TokenPurchase(msg.sender, contributionInWei, tokenAmount);
        return true;
    }
    function addToAllocationList(address user, uint256 amount)
        public
        onlyOwner
        atRound(SaleRounds.EarlyInvestment)
    {
        allocationList[user].isAllowed = true;
        allocationList[user].allowedAmount = amount;
    }
    function addManyToAllocationList(address[] users, uint256[] amounts)
        external
        onlyOwner
        atRound(SaleRounds.EarlyInvestment)
    {
        require(users.length == amounts.length);
        for (uint32 i = 0; i < users.length; i++) {
            addToAllocationList(users[i], amounts[i]);
        }
    }
    function removeFromAllocationList(address user)
        public
        onlyOwner
        atRound(SaleRounds.EarlyInvestment)
    {
        allocationList[user].isAllowed = false;
    }
    function removeManyFromAllocationList(address[] users)
        external
        onlyOwner
        atRound(SaleRounds.EarlyInvestment)
    {
        for (uint32 i = 0; i < users.length; i++) {
            removeFromAllocationList(users[i]);
        }
    }
    function allocateTokens(address to, uint256 tokenAmount)
        public
        onlyOwner
        atRound(SaleRounds.EarlyInvestment)
        returns (bool)
    {
        require(allocationList[to].isAllowed
            && tokenAmount <= allocationList[to].allowedAmount);
        if (!token.transferFrom(token.owner(), to, tokenAmount)) {
            revert();
        }
        return true;
    }
    function allocateTokensToMany(address[] toList, uint256[] tokenAmountList)
        external
        onlyOwner
        atRound(SaleRounds.EarlyInvestment)
        returns (bool)
    {
        require(toList.length == tokenAmountList.length);
        for (uint32 i = 0; i < toList.length; i++) {
            allocateTokens(toList[i], tokenAmountList[i]);
        }
        return true;
    }
}
