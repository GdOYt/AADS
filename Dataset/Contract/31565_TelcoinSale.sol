contract TelcoinSale {
    using SafeMath for uint256;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event WalletChanged(address indexed previousWallet, address indexed newWallet);
    event TokenPurchase(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount,
        uint256 bonusAmount
    );
    event TokenAltPurchase(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount,
        uint256 bonusAmount,
        string symbol,
        string transactionId
    );
    event Pause();
    event Unpause();
    event Withdrawal(address indexed wallet, uint256 weiAmount);
    event Extended(uint256 until);
    event Finalized();
    event Refunding();
    event Refunded(address indexed beneficiary, uint256 weiAmount);
    event Whitelisted(
        address indexed participant,
        uint256 minWeiAmount,
        uint256 maxWeiAmount,
        uint32 bonusRate
    );
    event CapFlexed(uint32 flex);
    address public owner;
    TelcoinSaleToken public saleToken;
    TelcoinSaleToken public bonusToken;
    Telcoin public telcoin;
    uint256 public softCap;
    uint256 public hardCap;
    uint32 public capFlex;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public timeExtension;
    uint256 public rate;
    uint256 public weiRaised;
    address public wallet;
    mapping(address => uint256) public whitelistedMin;
    mapping(address => uint256) public whitelistedMax;
    mapping(address => uint32) public bonusRates;
    mapping(address => uint256) public deposited;
    mapping(address => uint256) public altDeposited;
    address[] public investors;
    bool public paused = false;
    bool public finished = false;
    uint256 public finishedAt;
    bool public refunding = false;
    uint256 public weiRefunded;
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    modifier saleOpen() {
        require(!finished);
        require(!paused);
        require(now >= startTime);
        require(now <= endTime + timeExtension);
        _;
    }
    function TelcoinSale(
        uint256 _softCap,
        uint256 _hardCap,
        uint32 _capFlex,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _rate,
        address _wallet,
        Telcoin _telcoin,
        uint256 _bonusVestingStart,
        uint256 _bonusVestingDuration
    )
        public
        payable
    {
        require(msg.value > 0);
        require(_softCap > 0);
        require(_hardCap >= _softCap);
        require(_startTime >= now);
        require(_endTime >= _startTime);
        require(_rate > 0);
        require(_wallet != 0x0);
        owner = msg.sender;
        softCap = _softCap;
        hardCap = _hardCap;
        capFlex = _capFlex;
        startTime = _startTime;
        endTime = _endTime;
        rate = _rate;
        wallet = _wallet;
        telcoin = _telcoin;
        saleToken = new TelcoinSaleToken(telcoin, 0, 0);
        bonusToken = new TelcoinSaleToken(
            telcoin,
            _bonusVestingStart,
            _bonusVestingDuration
        );
        wallet.transfer(msg.value);
    }
    function () public payable {
        buyTokens(msg.sender);
    }
    function buyTokens(address _beneficiary) saleOpen public payable {
        require(_beneficiary != address(0));
        uint256 weiAmount = msg.value;
        require(weiAmount > 0);
        require(weiRaised.add(weiAmount) <= hardCap);
        uint256 totalPrior = totalDeposited(_beneficiary);
        uint256 totalAfter = totalPrior.add(weiAmount);
        require(totalAfter <= whitelistedMax[_beneficiary]);
        uint256 saleTokens;
        uint256 bonusTokens;
        (saleTokens, bonusTokens) = tokensForPurchase(_beneficiary, weiAmount);
        uint256 newDeposited = deposited[_beneficiary].add(weiAmount);
        deposited[_beneficiary] = newDeposited;
        investors.push(_beneficiary);
        weiRaised = weiRaised.add(weiAmount);
        saleToken.mint(_beneficiary, saleTokens);
        if (bonusTokens > 0) {
            bonusToken.mint(_beneficiary, bonusTokens);
        }
        TokenPurchase(
            msg.sender,
            _beneficiary,
            weiAmount,
            saleTokens,
            bonusTokens
        );
    }
    function changeWallet(address _wallet) onlyOwner public payable {
        require(_wallet != 0x0);
        require(msg.value > 0);
        WalletChanged(wallet, _wallet);
        wallet = _wallet;
        wallet.transfer(msg.value);
    }
    function extendTime(uint256 _timeExtension) onlyOwner public {
        require(!finished);
        require(now < endTime + timeExtension);
        require(_timeExtension > 0);
        timeExtension = timeExtension.add(_timeExtension);
        require(timeExtension <= 7 days);
        Extended(endTime.add(timeExtension));
    }
    function finish() onlyOwner public {
        require(!finished);
        require(hardCapReached() || now > endTime + timeExtension);
        finished = true;
        finishedAt = now;
        saleToken.finishMinting();
        bonusToken.finishMinting();
        uint256 distributableCoins = telcoin.balanceOf(this);
        if (softCapReached()) {
            uint256 saleTokens = saleToken.totalSupply();
            uint256 bonusTokens = bonusToken.totalSupply();
            uint256 totalTokens = saleTokens.add(bonusTokens);
            uint256 bonusPortion = bonusTokens.mul(10 ** 18).div(totalTokens).mul(distributableCoins).div(10 ** 18);
            uint256 salePortion = distributableCoins.sub(bonusPortion);
            saleToken.transferOwnership(owner);
            bonusToken.transferOwnership(owner);
            telcoin.transfer(saleToken, salePortion);
            telcoin.transfer(bonusToken, bonusPortion);
            withdraw();
        } else {
            refunding = true;
            telcoin.transfer(wallet, distributableCoins);
            Refunding();
        }
        Finalized();
    }
    function pause() onlyOwner public {
        require(!paused);
        paused = true;
        Pause();
    }
    function refundMany(address[] _investors) public {
        for (uint256 i = 0; i < _investors.length; i++) {
            refund(_investors[i]);
        }
    }
    function refund(address _investor) public {
        require(finished);
        require(refunding);
        require(deposited[_investor] > 0);
        uint256 weiAmount = deposited[_investor];
        deposited[_investor] = 0;
        weiRefunded = weiRefunded.add(weiAmount);
        Refunded(_investor, weiAmount);
        _investor.transfer(weiAmount);
    }
    function registerAltPurchase(
        address _beneficiary,
        string _symbol,
        string _transactionId,
        uint256 _weiAmount
    )
        saleOpen
        onlyOwner
        public
    {
        require(_beneficiary != address(0));
        require(totalDeposited(_beneficiary).add(_weiAmount) <= whitelistedMax[_beneficiary]);
        uint256 saleTokens;
        uint256 bonusTokens;
        (saleTokens, bonusTokens) = tokensForPurchase(_beneficiary, _weiAmount);
        uint256 newAltDeposited = altDeposited[_beneficiary].add(_weiAmount);
        altDeposited[_beneficiary] = newAltDeposited;
        investors.push(_beneficiary);
        weiRaised = weiRaised.add(_weiAmount);
        saleToken.mint(_beneficiary, saleTokens);
        if (bonusTokens > 0) {
            bonusToken.mint(_beneficiary, bonusTokens);
        }
        TokenAltPurchase(
            msg.sender,
            _beneficiary,
            _weiAmount,
            saleTokens,
            bonusTokens,
            _symbol,
            _transactionId
        );
    }
    function transferOwnership(address _to) onlyOwner public {
        require(_to != address(0));
        OwnershipTransferred(owner, _to);
        owner = _to;
    }
    function unpause() onlyOwner public {
        require(paused);
        paused = false;
        Unpause();
    }
    function updateCapFlex(uint32 _capFlex) onlyOwner public {
        require(!finished);
        capFlex = _capFlex;
        CapFlexed(capFlex);
    }
    function whitelistMany(
        address[] _participants,
        uint256 _minWeiAmount,
        uint256 _maxWeiAmount,
        uint32 _bonusRate
    )
        onlyOwner
        public
    {
        for (uint256 i = 0; i < _participants.length; i++) {
            whitelist(
                _participants[i],
                _minWeiAmount,
                _maxWeiAmount,
                _bonusRate
            );
        }
    }
    function whitelist(
        address _participant,
        uint256 _minWeiAmount,
        uint256 _maxWeiAmount,
        uint32 _bonusRate
    )
        onlyOwner
        public
    {
        require(_participant != 0x0);
        require(_bonusRate <= 400);
        whitelistedMin[_participant] = _minWeiAmount;
        whitelistedMax[_participant] = _maxWeiAmount;
        bonusRates[_participant] = _bonusRate;
        Whitelisted(
            _participant,
            _minWeiAmount,
            _maxWeiAmount,
            _bonusRate
        );
    }
    function withdraw() onlyOwner public {
        require(softCapReached() || (finished && now > finishedAt + 14 days));
        uint256 weiAmount = this.balance;
        if (weiAmount > 0) {
            wallet.transfer(weiAmount);
            Withdrawal(wallet, weiAmount);
        }
    }
    function hardCapReached() public constant returns (bool) {
        return weiRaised >= hardCap.mul(1000 + capFlex).div(1000);
    }
    function tokensForPurchase(
        address _beneficiary,
        uint256 _weiAmount
    )
        public
        constant
        returns (uint256, uint256)
    {
        uint256 baseTokens = _weiAmount.mul(rate);
        uint256 totalPrior = totalDeposited(_beneficiary);
        uint256 totalAfter = totalPrior.add(_weiAmount);
        if (totalAfter < whitelistedMin[_beneficiary]) {
            return (baseTokens, 0);
        }
        uint32 bonusRate = bonusRates[_beneficiary];
        uint256 baseBonus = baseTokens.mul(1000 + bonusRate).div(1000).sub(baseTokens);
        if (totalPrior < whitelistedMin[_beneficiary]) {
            uint256 balancePrior = totalPrior.mul(rate);
            uint256 accumulatedBonus = balancePrior.mul(1000 + bonusRate).div(1000).sub(balancePrior);
            return (baseTokens, accumulatedBonus.add(baseBonus));
        }
        return (baseTokens, baseBonus);
    }
    function totalDeposited(address _investor) public constant returns (uint256) {
        return deposited[_investor].add(altDeposited[_investor]);
    }
    function softCapReached() public constant returns (bool) {
        return weiRaised >= softCap.mul(1000 + capFlex).div(1000);
    }
}
