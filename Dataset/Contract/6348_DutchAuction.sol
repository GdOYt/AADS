contract DutchAuction {
    uint constant public TOKEN_CLAIM_WAITING_PERIOD = 7 days;
    LetsbetToken public token;
    address public ownerAddress;
    address public walletAddress;
    uint public startPrice;
    uint public priceDecreaseRate;
    uint public startTime;
    uint public endTimeOfBids;
    uint public finalizedTime;
    uint public startBlock;
    uint public receivedWei;
    uint public fundsClaimed;
    uint public tokenMultiplier;
    uint public tokensAuctioned;
    uint public finalPrice;
    mapping (address => uint) public bids;
    Stages public stage;
    enum Stages {
        AuctionDeployed,
        AuctionSetUp,
        AuctionStarted,
        AuctionEnded,
        TokensDistributed
    }
    modifier atStage(Stages _stage) {
        require(stage == _stage);
        _;
    }
    modifier isOwner() {
        require(msg.sender == ownerAddress);
        _;
    }
    event Deployed(
        uint indexed _startPrice,
        uint indexed _priceDecreaseRate
    );
	event Setup();
	event AuctionStarted(uint indexed _startTime, uint indexed _blockNumber);
	event BidSubmission(
        address indexed sender,
        uint amount,
        uint missingFunds,
        uint timestamp
    );
	event ClaimedTokens(address indexed _recipient, uint _sentAmount);
	event AuctionEnded(uint _finalPrice);
	event TokensDistributed();
    function DutchAuction(
        address _walletAddress,
        uint _startPrice,
        uint _priceDecreaseRate,
        uint _endTimeOfBids) 
    public
    {
        require(_walletAddress != 0x0);
        walletAddress = _walletAddress;
        ownerAddress = msg.sender;
        stage = Stages.AuctionDeployed;
        changeSettings(_startPrice, _priceDecreaseRate,_endTimeOfBids);
        Deployed(_startPrice, _priceDecreaseRate);
    }
    function () public payable atStage(Stages.AuctionStarted) {
        bid();
    }
    function setup(address _tokenAddress) public isOwner atStage(Stages.AuctionDeployed) {
        require(_tokenAddress != 0x0);
        token = LetsbetToken(_tokenAddress);
        tokensAuctioned = token.balanceOf(address(this));
        tokenMultiplier = 10 ** uint(token.decimals());
        stage = Stages.AuctionSetUp;
        Setup();
    }
    function changeSettings(
        uint _startPrice,
        uint _priceDecreaseRate,
        uint _endTimeOfBids
        )
        internal
    {
        require(stage == Stages.AuctionDeployed || stage == Stages.AuctionSetUp);
        require(_startPrice > 0);
        require(_priceDecreaseRate > 0);
        require(_endTimeOfBids > now);
        endTimeOfBids = _endTimeOfBids;
        startPrice = _startPrice;
        priceDecreaseRate = _priceDecreaseRate;
    }
    function startAuction() public isOwner atStage(Stages.AuctionSetUp) {
        stage = Stages.AuctionStarted;
        startTime = now;
        startBlock = block.number;
        AuctionStarted(startTime, startBlock);
    }
    function finalizeAuction() public isOwner atStage(Stages.AuctionStarted) {
        uint missingFunds = missingFundsToEndAuction();
        require(missingFunds == 0 || now > endTimeOfBids);
        finalPrice = tokenMultiplier * receivedWei / tokensAuctioned;
        finalizedTime = now;
        stage = Stages.AuctionEnded;
        AuctionEnded(finalPrice);
        assert(finalPrice > 0);
    }
    function bid()
        public
        payable
        atStage(Stages.AuctionStarted)
    {
        require(msg.value > 0);
        assert(bids[msg.sender] + msg.value >= msg.value);
        uint missingFunds = missingFundsToEndAuction();
        require(msg.value <= missingFunds);
        bids[msg.sender] += msg.value;
        receivedWei += msg.value;
        walletAddress.transfer(msg.value);
        BidSubmission(msg.sender, msg.value, missingFunds,block.timestamp);
        assert(receivedWei >= msg.value);
    }
    function claimTokens() public atStage(Stages.AuctionEnded) returns (bool) {
        return proxyClaimTokens(msg.sender);
    }
    function proxyClaimTokens(address receiverAddress)
        public
        atStage(Stages.AuctionEnded)
        returns (bool)
    {
        require(now > finalizedTime + TOKEN_CLAIM_WAITING_PERIOD);
        require(receiverAddress != 0x0);
        if (bids[receiverAddress] == 0) {
            return false;
        }
        uint num = (tokenMultiplier * bids[receiverAddress]) / finalPrice;
        uint auctionTokensBalance = token.balanceOf(address(this));
        if (num > auctionTokensBalance) {
            num = auctionTokensBalance;
        }
        fundsClaimed += bids[receiverAddress];
        bids[receiverAddress] = 0;
        require(token.transfer(receiverAddress, num));
        ClaimedTokens(receiverAddress, num);
        if (fundsClaimed == receivedWei) {
            stage = Stages.TokensDistributed;
            TokensDistributed();
        }
        assert(token.balanceOf(receiverAddress) >= num);
        assert(bids[receiverAddress] == 0);
        return true;
    }
    function price() public constant returns (uint) {
        if (stage == Stages.AuctionEnded ||
            stage == Stages.TokensDistributed) {
            return finalPrice;
        }
        return calcTokenPrice();
    }
    function missingFundsToEndAuction() constant public returns (uint) {
        uint requiredWei = tokensAuctioned * price() / tokenMultiplier;
        if (requiredWei <= receivedWei) {
            return 0;
        }
        return requiredWei - receivedWei;
    }
    function calcTokenPrice() constant private returns (uint) {
        uint currentPrice;
        if (stage == Stages.AuctionStarted) {
            currentPrice = startPrice - priceDecreaseRate * (block.number - startBlock);
        }else {
            currentPrice = startPrice;
        }
        return currentPrice;
    }
}
