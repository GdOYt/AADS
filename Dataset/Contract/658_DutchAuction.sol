contract DutchAuction {
    event BidSubmission(address indexed sender, uint256 amount);
    uint constant public MAX_TOKENS_SOLD = 800 * 10**9;  
    uint constant public WAITING_PERIOD = 30 minutes;
    XRT     public xrt;
    address public ambix;
    address public wallet;
    address public owner;
    uint public ceiling;
    uint public priceFactor;
    uint public startBlock;
    uint public endTime;
    uint public totalReceived;
    uint public finalPrice;
    mapping (address => uint) public bids;
    Stages public stage;
    enum Stages {
        AuctionDeployed,
        AuctionSetUp,
        AuctionStarted,
        AuctionEnded,
        TradingStarted
    }
    modifier atStage(Stages _stage) {
        require(stage == _stage);
        _;
    }
    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }
    modifier isWallet() {
        require(msg.sender == wallet);
        _;
    }
    modifier isValidPayload() {
        require(msg.data.length == 4 || msg.data.length == 36);
        _;
    }
    modifier timedTransitions() {
        if (stage == Stages.AuctionStarted && calcTokenPrice() <= calcStopPrice())
            finalizeAuction();
        if (stage == Stages.AuctionEnded && now > endTime + WAITING_PERIOD)
            stage = Stages.TradingStarted;
        _;
    }
    constructor(address _wallet, uint _ceiling, uint _priceFactor)
        public
    {
        require(_wallet != 0 && _ceiling != 0 && _priceFactor != 0);
        owner = msg.sender;
        wallet = _wallet;
        ceiling = _ceiling;
        priceFactor = _priceFactor;
        stage = Stages.AuctionDeployed;
    }
    function setup(address _xrt, address _ambix)
        public
        isOwner
        atStage(Stages.AuctionDeployed)
    {
        require(_xrt != 0 && _ambix != 0);
        xrt = XRT(_xrt);
        ambix = _ambix;
        require(xrt.balanceOf(this) == MAX_TOKENS_SOLD);
        stage = Stages.AuctionSetUp;
    }
    function startAuction()
        public
        isWallet
        atStage(Stages.AuctionSetUp)
    {
        stage = Stages.AuctionStarted;
        startBlock = block.number;
    }
    function changeSettings(uint _ceiling, uint _priceFactor)
        public
        isWallet
        atStage(Stages.AuctionSetUp)
    {
        ceiling = _ceiling;
        priceFactor = _priceFactor;
    }
    function calcCurrentTokenPrice()
        public
        timedTransitions
        returns (uint)
    {
        if (stage == Stages.AuctionEnded || stage == Stages.TradingStarted)
            return finalPrice;
        return calcTokenPrice();
    }
    function updateStage()
        public
        timedTransitions
        returns (Stages)
    {
        return stage;
    }
    function bid(address receiver)
        public
        payable
        isValidPayload
        timedTransitions
        atStage(Stages.AuctionStarted)
        returns (uint amount)
    {
        require(msg.value > 0);
        amount = msg.value;
        if (receiver == 0)
            receiver = msg.sender;
        uint maxWei = MAX_TOKENS_SOLD * calcTokenPrice() / 10**9 - totalReceived;
        uint maxWeiBasedOnTotalReceived = ceiling - totalReceived;
        if (maxWeiBasedOnTotalReceived < maxWei)
            maxWei = maxWeiBasedOnTotalReceived;
        if (amount > maxWei) {
            amount = maxWei;
            receiver.transfer(msg.value - amount);
        }
        wallet.transfer(amount);
        bids[receiver] += amount;
        totalReceived += amount;
        BidSubmission(receiver, amount);
        if (amount == maxWei)
            finalizeAuction();
    }
    function claimTokens(address receiver)
        public
        isValidPayload
        timedTransitions
        atStage(Stages.TradingStarted)
    {
        if (receiver == 0)
            receiver = msg.sender;
        uint tokenCount = bids[receiver] * 10**9 / finalPrice;
        bids[receiver] = 0;
        require(xrt.transfer(receiver, tokenCount));
    }
    function calcStopPrice()
        view
        public
        returns (uint)
    {
        return totalReceived * 10**9 / MAX_TOKENS_SOLD + 1;
    }
    function calcTokenPrice()
        view
        public
        returns (uint)
    {
        return priceFactor * 10**18 / (block.number - startBlock + 7500) + 1;
    }
    function finalizeAuction()
        private
    {
        stage = Stages.AuctionEnded;
        finalPrice = totalReceived == ceiling ? calcTokenPrice() : calcStopPrice();
        uint soldTokens = totalReceived * 10**9 / finalPrice;
        if (totalReceived == ceiling) {
            require(xrt.transfer(ambix, MAX_TOKENS_SOLD - soldTokens));
        } else {
            xrt.burn(MAX_TOKENS_SOLD - soldTokens);
        }
        endTime = now;
    }
}
