contract IssuanceController is SafeDecimalMath, SelfDestructible, Pausable {
    Havven public havven;
    Nomin public nomin;
    address public fundsWallet;
    address public oracle;
    uint constant ORACLE_FUTURE_LIMIT = 10 minutes;
    uint public priceStalePeriod = 3 hours;
    uint public lastPriceUpdateTime;
    uint public usdToHavPrice;
    uint public usdToEthPrice;
    constructor(
        address _owner,
        address _fundsWallet,
        Havven _havven,
        Nomin _nomin,
        address _oracle,
        uint _usdToEthPrice,
        uint _usdToHavPrice
    )
        SelfDestructible(_owner)
        Pausable(_owner)
        public
    {
        fundsWallet = _fundsWallet;
        havven = _havven;
        nomin = _nomin;
        oracle = _oracle;
        usdToEthPrice = _usdToEthPrice;
        usdToHavPrice = _usdToHavPrice;
        lastPriceUpdateTime = now;
    }
    function setFundsWallet(address _fundsWallet)
        external
        onlyOwner
    {
        fundsWallet = _fundsWallet;
        emit FundsWalletUpdated(fundsWallet);
    }
    function setOracle(address _oracle)
        external
        onlyOwner
    {
        oracle = _oracle;
        emit OracleUpdated(oracle);
    }
    function setNomin(Nomin _nomin)
        external
        onlyOwner
    {
        nomin = _nomin;
        emit NominUpdated(_nomin);
    }
    function setHavven(Havven _havven)
        external
        onlyOwner
    {
        havven = _havven;
        emit HavvenUpdated(_havven);
    }
    function setPriceStalePeriod(uint _time)
        external
        onlyOwner 
    {
        priceStalePeriod = _time;
        emit PriceStalePeriodUpdated(priceStalePeriod);
    }
    function updatePrices(uint newEthPrice, uint newHavvenPrice, uint timeSent)
        external
        onlyOracle
    {
        require(lastPriceUpdateTime < timeSent && timeSent < now + ORACLE_FUTURE_LIMIT, 
            "Time sent must be bigger than the last update, and must be less than now + ORACLE_FUTURE_LIMIT");
        usdToEthPrice = newEthPrice;
        usdToHavPrice = newHavvenPrice;
        lastPriceUpdateTime = timeSent;
        emit PricesUpdated(usdToEthPrice, usdToHavPrice, lastPriceUpdateTime);
    }
    function ()
        external
        payable
    {
        exchangeEtherForNomins();
    } 
    function exchangeEtherForNomins()
        public 
        payable
        pricesNotStale
        notPaused
        returns (uint)  
    {
        uint requestedToPurchase = safeMul_dec(msg.value, usdToEthPrice);
        fundsWallet.transfer(msg.value);
        nomin.transfer(msg.sender, requestedToPurchase);
        emit Exchange("ETH", msg.value, "nUSD", requestedToPurchase);
        return requestedToPurchase;
    }
    function exchangeEtherForNominsAtRate(uint guaranteedRate)
        public
        payable
        pricesNotStale
        notPaused
        returns (uint)  
    {
        require(guaranteedRate == usdToEthPrice);
        return exchangeEtherForNomins();
    }
    function exchangeEtherForHavvens()
        public 
        payable
        pricesNotStale
        notPaused
        returns (uint)  
    {
        uint havvensToSend = havvensReceivedForEther(msg.value);
        fundsWallet.transfer(msg.value);
        havven.transfer(msg.sender, havvensToSend);
        emit Exchange("ETH", msg.value, "HAV", havvensToSend);
        return havvensToSend;
    }
    function exchangeEtherForHavvensAtRate(uint guaranteedEtherRate, uint guaranteedHavvenRate)
        public
        payable
        pricesNotStale
        notPaused
        returns (uint)  
    {
        require(guaranteedEtherRate == usdToEthPrice);
        require(guaranteedHavvenRate == usdToHavPrice);
        return exchangeEtherForHavvens();
    }
    function exchangeNominsForHavvens(uint nominAmount)
        public 
        pricesNotStale
        notPaused
        returns (uint)  
    {
        uint havvensToSend = havvensReceivedForNomins(nominAmount);
        nomin.transferFrom(msg.sender, this, nominAmount);
        havven.transfer(msg.sender, havvensToSend);
        emit Exchange("nUSD", nominAmount, "HAV", havvensToSend);
        return havvensToSend; 
    }
    function exchangeNominsForHavvensAtRate(uint nominAmount, uint guaranteedRate)
        public 
        pricesNotStale
        notPaused
        returns (uint)  
    {
        require(guaranteedRate == usdToHavPrice);
        return exchangeNominsForHavvens(nominAmount);
    }
    function withdrawHavvens(uint amount)
        external
        onlyOwner
    {
        havven.transfer(owner, amount);
    }
    function withdrawNomins(uint amount)
        external
        onlyOwner
    {
        nomin.transfer(owner, amount);
    }
    function pricesAreStale()
        public
        view
        returns (bool)
    {
        return safeAdd(lastPriceUpdateTime, priceStalePeriod) < now;
    }
    function havvensReceivedForNomins(uint amount)
        public 
        view
        returns (uint)
    {
        uint nominsReceived = nomin.amountReceived(amount);
        return safeDiv_dec(nominsReceived, usdToHavPrice);
    }
    function havvensReceivedForEther(uint amount)
        public 
        view
        returns (uint)
    {
        uint valueSentInNomins = safeMul_dec(amount, usdToEthPrice); 
        return havvensReceivedForNomins(valueSentInNomins);
    }
    function nominsReceivedForEther(uint amount)
        public 
        view
        returns (uint)
    {
        uint nominsTransferred = safeMul_dec(amount, usdToEthPrice);
        return nomin.amountReceived(nominsTransferred);
    }
    modifier onlyOracle
    {
        require(msg.sender == oracle, "Must be oracle to perform this action");
        _;
    }
    modifier pricesNotStale
    {
        require(!pricesAreStale(), "Prices must not be stale to perform this action");
        _;
    }
    event FundsWalletUpdated(address newFundsWallet);
    event OracleUpdated(address newOracle);
    event NominUpdated(Nomin newNominContract);
    event HavvenUpdated(Havven newHavvenContract);
    event PriceStalePeriodUpdated(uint priceStalePeriod);
    event PricesUpdated(uint newEthPrice, uint newHavvenPrice, uint timeSent);
    event Exchange(string fromCurrency, uint fromAmount, string toCurrency, uint toAmount);
}
