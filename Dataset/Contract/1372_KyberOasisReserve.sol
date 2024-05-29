contract KyberOasisReserve is KyberReserveInterface, Withdrawable, Utils2 {
    uint constant internal MIN_TRADE_TOKEN_SRC_AMOUNT = (10**18);
    uint constant internal COMMON_DECIMALS = 18;
    address public sanityRatesContract = 0;
    address public kyberNetwork;
    OtcInterface public otc;
    TokenInterface public wethToken;
    ERC20 public tradeToken;
    bool public tradeEnabled;
    uint public feeBps;
    function KyberOasisReserve(
        address _kyberNetwork,
        OtcInterface _otc,
        TokenInterface _wethToken,
        ERC20 _tradeToken,
        address _admin,
        uint _feeBps
    )
        public
    {
        require(_admin != address(0));
        require(_kyberNetwork != address(0));
        require(_otc != address(0));
        require(_wethToken != address(0));
        require(_tradeToken != address(0));
        require(_feeBps < 10000);
        require(getDecimals(_wethToken) == COMMON_DECIMALS);
        require(getDecimals(_tradeToken) == COMMON_DECIMALS);
        kyberNetwork = _kyberNetwork;
        otc = _otc;
        wethToken = _wethToken;
        tradeToken = _tradeToken;
        admin = _admin;
        feeBps = _feeBps;
        tradeEnabled = true;
        wethToken.approve(otc, 2**255);
        tradeToken.approve(otc, 2**255);
    }
    function() public payable {
        require(msg.sender == address(wethToken));
    }
    event TradeExecute(
        address indexed sender,
        address src,
        uint srcAmount,
        address destToken,
        uint destAmount,
        address destAddress
    );
    function trade(
        ERC20 srcToken,
        uint srcAmount,
        ERC20 destToken,
        address destAddress,
        uint conversionRate,
        bool validate
    )
        public
        payable
        returns(bool)
    {
        require(tradeEnabled);
        require(msg.sender == kyberNetwork);
        require(doTrade(srcToken, srcAmount, destToken, destAddress, conversionRate, validate));
        return true;
    }
    event TradeEnabled(bool enable);
    function enableTrade() public onlyAdmin returns(bool) {
        tradeEnabled = true;
        TradeEnabled(true);
        return true;
    }
    function disableTrade() public onlyAlerter returns(bool) {
        tradeEnabled = false;
        TradeEnabled(false);
        return true;
    }
    event KyberNetworkSet(address kyberNetwork);
    function setKyberNetwork(address _kyberNetwork) public onlyAdmin {
        require(_kyberNetwork != address(0));
        kyberNetwork = _kyberNetwork;
        KyberNetworkSet(kyberNetwork);
    }
    event OtcSet(address otc);
    function setOtc(OtcInterface _otc) public onlyAdmin {
        require(_otc != address(0));
        wethToken.approve(otc, 0);
        tradeToken.approve(otc, 0);
        wethToken.approve(_otc, 2**255);
        tradeToken.approve(_otc, 2**255);
        otc = _otc;
        OtcSet(otc);
    }
    event FeeBpsSet(uint feeBps);
    function setFeeBps(uint _feeBps) public onlyAdmin {
        require(_feeBps < 10000);
        feeBps = _feeBps;
        FeeBpsSet(feeBps);
    }
    function valueAfterReducingFee(uint val) public view returns(uint) {
        require(val <= MAX_QTY);
        return ((10000 - feeBps) * val) / 10000;
    }
    function valueBeforeFeesWereReduced(uint val) public view returns(uint) {
        require(val <= MAX_QTY);
        return val * 10000 / (10000 - feeBps);
    }
    function getConversionRate(ERC20 src, ERC20 dest, uint srcQty, uint blockNumber) public view returns(uint) {
        uint  rate;
        uint  actualSrcQty;
        ERC20 wrappedSrc;
        ERC20 wrappedDest;
        uint  bestOfferId;
        uint  offerPayAmt;
        uint  offerBuyAmt;
        blockNumber;
        if (!tradeEnabled) return 0;
        if ((tradeToken != src) && (tradeToken != dest)) return 0;
        if (src == ETH_TOKEN_ADDRESS) {
            wrappedSrc = wethToken;
            wrappedDest = dest;
            actualSrcQty = srcQty;
        } else if (dest == ETH_TOKEN_ADDRESS) {
            wrappedSrc = src;
            wrappedDest = wethToken;
            if (srcQty < MIN_TRADE_TOKEN_SRC_AMOUNT) {
                actualSrcQty = MIN_TRADE_TOKEN_SRC_AMOUNT;
            } else {
                actualSrcQty = srcQty;
            }
        } else {
            return 0;
        }
        bestOfferId = otc.getBestOffer(wrappedDest, wrappedSrc);
        (offerPayAmt, , offerBuyAmt,) = otc.getOffer(bestOfferId);
        if (actualSrcQty > offerBuyAmt) return 0;
        rate = calcRateFromQty(offerBuyAmt, offerPayAmt, COMMON_DECIMALS, COMMON_DECIMALS);
        return valueAfterReducingFee(rate);
    }
    function doTrade(
        ERC20 srcToken,
        uint srcAmount,
        ERC20 destToken,
        address destAddress,
        uint conversionRate,
        bool validate
    )
        internal
        returns(bool)
    {
        require((ETH_TOKEN_ADDRESS == srcToken) || (ETH_TOKEN_ADDRESS == destToken));
        require((tradeToken == srcToken) || (tradeToken == destToken));
        uint actualDestAmount;
        if (validate) {
            require(conversionRate > 0);
            if (srcToken == ETH_TOKEN_ADDRESS)
                require(msg.value == srcAmount);
            else
                require(msg.value == 0);
        }
        uint userExpectedDestAmount = calcDstQty(srcAmount, COMMON_DECIMALS, COMMON_DECIMALS, conversionRate);
        require(userExpectedDestAmount > 0);  
        uint destAmountIncludingFees = valueBeforeFeesWereReduced(userExpectedDestAmount);
        if (srcToken == ETH_TOKEN_ADDRESS) {
            wethToken.deposit.value(msg.value)();
            actualDestAmount = otc.sellAllAmount(wethToken, msg.value, destToken, destAmountIncludingFees);
            require(actualDestAmount >= destAmountIncludingFees);
            require(destToken.transfer(destAddress, userExpectedDestAmount));
        } else {
            require(srcToken.transferFrom(msg.sender, this, srcAmount));
            actualDestAmount = otc.sellAllAmount(srcToken, srcAmount, wethToken, destAmountIncludingFees);
            require(actualDestAmount >= destAmountIncludingFees);
            wethToken.withdraw(actualDestAmount);
            destAddress.transfer(userExpectedDestAmount); 
        }
        TradeExecute(msg.sender, srcToken, srcAmount, destToken, userExpectedDestAmount, destAddress);
        return true;
    }
}
