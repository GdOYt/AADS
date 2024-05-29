contract Havven is ExternStateToken {
    struct IssuanceData {
        uint currentBalanceSum;
        uint lastAverageBalance;
        uint lastModified;
    }
    mapping(address => IssuanceData) public issuanceData;
    IssuanceData public totalIssuanceData;
    uint public feePeriodStartTime;
    uint public lastFeePeriodStartTime;
    uint public feePeriodDuration = 4 weeks;
    uint constant MIN_FEE_PERIOD_DURATION = 1 days;
    uint constant MAX_FEE_PERIOD_DURATION = 26 weeks;
    uint public lastFeesCollected;
    mapping(address => bool) public hasWithdrawnFees;
    Nomin public nomin;
    HavvenEscrow public escrow;
    address public oracle;
    uint public price;
    uint public lastPriceUpdateTime;
    uint public priceStalePeriod = 3 hours;
    uint public issuanceRatio = UNIT / 5;
    uint constant MAX_ISSUANCE_RATIO = UNIT;
    mapping(address => bool) public isIssuer;
    mapping(address => uint) public nominsIssued;
    uint constant HAVVEN_SUPPLY = 1e8 * UNIT;
    uint constant ORACLE_FUTURE_LIMIT = 10 minutes;
    string constant TOKEN_NAME = "Havven";
    string constant TOKEN_SYMBOL = "HAV";
    constructor(address _proxy, TokenState _tokenState, address _owner, address _oracle,
                uint _price, address[] _issuers, Havven _oldHavven)
        ExternStateToken(_proxy, _tokenState, TOKEN_NAME, TOKEN_SYMBOL, HAVVEN_SUPPLY, _owner)
        public
    {
        oracle = _oracle;
        price = _price;
        lastPriceUpdateTime = now;
        uint i;
        if (_oldHavven == address(0)) {
            feePeriodStartTime = now;
            lastFeePeriodStartTime = now - feePeriodDuration;
            for (i = 0; i < _issuers.length; i++) {
                isIssuer[_issuers[i]] = true;
            }
        } else {
            feePeriodStartTime = _oldHavven.feePeriodStartTime();
            lastFeePeriodStartTime = _oldHavven.lastFeePeriodStartTime();
            uint cbs;
            uint lab;
            uint lm;
            (cbs, lab, lm) = _oldHavven.totalIssuanceData();
            totalIssuanceData.currentBalanceSum = cbs;
            totalIssuanceData.lastAverageBalance = lab;
            totalIssuanceData.lastModified = lm;
            for (i = 0; i < _issuers.length; i++) {
                address issuer = _issuers[i];
                isIssuer[issuer] = true;
                uint nomins = _oldHavven.nominsIssued(issuer);
                if (nomins == 0) {
                    continue;
                }
                (cbs, lab, lm) = _oldHavven.issuanceData(issuer);
                nominsIssued[issuer] = nomins;
                issuanceData[issuer].currentBalanceSum = cbs;
                issuanceData[issuer].lastAverageBalance = lab;
                issuanceData[issuer].lastModified = lm;
            }
        }
    }
    function setNomin(Nomin _nomin)
        external
        optionalProxy_onlyOwner
    {
        nomin = _nomin;
        emitNominUpdated(_nomin);
    }
    function setEscrow(HavvenEscrow _escrow)
        external
        optionalProxy_onlyOwner
    {
        escrow = _escrow;
        emitEscrowUpdated(_escrow);
    }
    function setFeePeriodDuration(uint duration)
        external
        optionalProxy_onlyOwner
    {
        require(MIN_FEE_PERIOD_DURATION <= duration && duration <= MAX_FEE_PERIOD_DURATION,
            "Duration must be between MIN_FEE_PERIOD_DURATION and MAX_FEE_PERIOD_DURATION");
        feePeriodDuration = duration;
        emitFeePeriodDurationUpdated(duration);
        rolloverFeePeriodIfElapsed();
    }
    function setOracle(address _oracle)
        external
        optionalProxy_onlyOwner
    {
        oracle = _oracle;
        emitOracleUpdated(_oracle);
    }
    function setPriceStalePeriod(uint time)
        external
        optionalProxy_onlyOwner
    {
        priceStalePeriod = time;
    }
    function setIssuanceRatio(uint _issuanceRatio)
        external
        optionalProxy_onlyOwner
    {
        require(_issuanceRatio <= MAX_ISSUANCE_RATIO, "New issuance ratio must be less than or equal to MAX_ISSUANCE_RATIO");
        issuanceRatio = _issuanceRatio;
        emitIssuanceRatioUpdated(_issuanceRatio);
    }
    function setIssuer(address account, bool value)
        external
        optionalProxy_onlyOwner
    {
        isIssuer[account] = value;
        emitIssuersUpdated(account, value);
    }
    function issuanceCurrentBalanceSum(address account)
        external
        view
        returns (uint)
    {
        return issuanceData[account].currentBalanceSum;
    }
    function issuanceLastAverageBalance(address account)
        external
        view
        returns (uint)
    {
        return issuanceData[account].lastAverageBalance;
    }
    function issuanceLastModified(address account)
        external
        view
        returns (uint)
    {
        return issuanceData[account].lastModified;
    }
    function totalIssuanceCurrentBalanceSum()
        external
        view
        returns (uint)
    {
        return totalIssuanceData.currentBalanceSum;
    }
    function totalIssuanceLastAverageBalance()
        external
        view
        returns (uint)
    {
        return totalIssuanceData.lastAverageBalance;
    }
    function totalIssuanceLastModified()
        external
        view
        returns (uint)
    {
        return totalIssuanceData.lastModified;
    }
    function transfer(address to, uint value)
        public
        optionalProxy
        returns (bool)
    {
        address sender = messageSender;
        require(nominsIssued[sender] == 0 || value <= transferableHavvens(sender), "Value to transfer exceeds available havvens");
        _transfer_byProxy(sender, to, value);
        return true;
    }
    function transferFrom(address from, address to, uint value)
        public
        optionalProxy
        returns (bool)
    {
        address sender = messageSender;
        require(nominsIssued[from] == 0 || value <= transferableHavvens(from), "Value to transfer exceeds available havvens");
        _transferFrom_byProxy(sender, from, to, value);
        return true;
    }
    function withdrawFees()
        external
        optionalProxy
    {
        address sender = messageSender;
        rolloverFeePeriodIfElapsed();
        require(!nomin.frozen(sender), "Cannot deposit fees into frozen accounts");
        updateIssuanceData(sender, nominsIssued[sender], nomin.totalSupply());
        require(!hasWithdrawnFees[sender], "Fees have already been withdrawn in this period");
        uint feesOwed;
        uint lastTotalIssued = totalIssuanceData.lastAverageBalance;
        if (lastTotalIssued > 0) {
            feesOwed = safeDiv_dec(
                safeMul_dec(issuanceData[sender].lastAverageBalance, lastFeesCollected),
                lastTotalIssued
            );
        }
        hasWithdrawnFees[sender] = true;
        if (feesOwed != 0) {
            nomin.withdrawFees(sender, feesOwed);
        }
        emitFeesWithdrawn(messageSender, feesOwed);
    }
    function updateIssuanceData(address account, uint preBalance, uint lastTotalSupply)
        internal
    {
        totalIssuanceData = computeIssuanceData(lastTotalSupply, totalIssuanceData);
        if (issuanceData[account].lastModified < feePeriodStartTime) {
            hasWithdrawnFees[account] = false;
        }
        issuanceData[account] = computeIssuanceData(preBalance, issuanceData[account]);
    }
    function computeIssuanceData(uint preBalance, IssuanceData preIssuance)
        internal
        view
        returns (IssuanceData)
    {
        uint currentBalanceSum = preIssuance.currentBalanceSum;
        uint lastAverageBalance = preIssuance.lastAverageBalance;
        uint lastModified = preIssuance.lastModified;
        if (lastModified < feePeriodStartTime) {
            if (lastModified < lastFeePeriodStartTime) {
                lastAverageBalance = preBalance;
            } else {
                uint timeUpToRollover = feePeriodStartTime - lastModified;
                uint lastFeePeriodDuration = feePeriodStartTime - lastFeePeriodStartTime;
                uint lastBalanceSum = safeAdd(currentBalanceSum, safeMul(preBalance, timeUpToRollover));
                lastAverageBalance = lastBalanceSum / lastFeePeriodDuration;
            }
            currentBalanceSum = safeMul(preBalance, now - feePeriodStartTime);
        } else {
            currentBalanceSum = safeAdd(
                currentBalanceSum,
                safeMul(preBalance, now - lastModified)
            );
        }
        return IssuanceData(currentBalanceSum, lastAverageBalance, now);
    }
    function recomputeLastAverageBalance(address account)
        external
        returns (uint)
    {
        updateIssuanceData(account, nominsIssued[account], nomin.totalSupply());
        return issuanceData[account].lastAverageBalance;
    }
    function issueNomins(uint amount)
        public
        optionalProxy
        requireIssuer(messageSender)
    {
        address sender = messageSender;
        require(amount <= remainingIssuableNomins(sender), "Amount must be less than or equal to remaining issuable nomins");
        uint lastTot = nomin.totalSupply();
        uint preIssued = nominsIssued[sender];
        nomin.issue(sender, amount);
        nominsIssued[sender] = safeAdd(preIssued, amount);
        updateIssuanceData(sender, preIssued, lastTot);
    }
    function issueMaxNomins()
        external
        optionalProxy
    {
        issueNomins(remainingIssuableNomins(messageSender));
    }
    function burnNomins(uint amount)
        external
        optionalProxy
    {
        address sender = messageSender;
        uint lastTot = nomin.totalSupply();
        uint preIssued = nominsIssued[sender];
        nomin.burn(sender, amount);
        nominsIssued[sender] = safeSub(preIssued, amount);
        updateIssuanceData(sender, preIssued, lastTot);
    }
    function rolloverFeePeriodIfElapsed()
        public
    {
        if (now >= feePeriodStartTime + feePeriodDuration) {
            lastFeesCollected = nomin.feePool();
            lastFeePeriodStartTime = feePeriodStartTime;
            feePeriodStartTime = now;
            emitFeePeriodRollover(now);
        }
    }
    function maxIssuableNomins(address issuer)
        view
        public
        priceNotStale
        returns (uint)
    {
        if (!isIssuer[issuer]) {
            return 0;
        }
        if (escrow != HavvenEscrow(0)) {
            uint totalOwnedHavvens = safeAdd(tokenState.balanceOf(issuer), escrow.balanceOf(issuer));
            return safeMul_dec(HAVtoUSD(totalOwnedHavvens), issuanceRatio);
        } else {
            return safeMul_dec(HAVtoUSD(tokenState.balanceOf(issuer)), issuanceRatio);
        }
    }
    function remainingIssuableNomins(address issuer)
        view
        public
        returns (uint)
    {
        uint issued = nominsIssued[issuer];
        uint max = maxIssuableNomins(issuer);
        if (issued > max) {
            return 0;
        } else {
            return safeSub(max, issued);
        }
    }
    function collateral(address account)
        public
        view
        returns (uint)
    {
        uint bal = tokenState.balanceOf(account);
        if (escrow != address(0)) {
            bal = safeAdd(bal, escrow.balanceOf(account));
        }
        return bal;
    }
    function issuanceDraft(address account)
        public
        view
        returns (uint)
    {
        uint issued = nominsIssued[account];
        if (issued == 0) {
            return 0;
        }
        return USDtoHAV(safeDiv_dec(issued, issuanceRatio));
    }
    function lockedCollateral(address account)
        public
        view
        returns (uint)
    {
        uint debt = issuanceDraft(account);
        uint collat = collateral(account);
        if (debt > collat) {
            return collat;
        }
        return debt;
    }
    function unlockedCollateral(address account)
        public
        view
        returns (uint)
    {
        uint locked = lockedCollateral(account);
        uint collat = collateral(account);
        return safeSub(collat, locked);
    }
    function transferableHavvens(address account)
        public
        view
        returns (uint)
    {
        uint draft = issuanceDraft(account);
        uint collat = collateral(account);
        if (draft > collat) {
            return 0;
        }
        uint bal = balanceOf(account);
        if (draft > safeSub(collat, bal)) {
            return safeSub(collat, draft);
        }
        return bal;
    }
    function HAVtoUSD(uint hav_dec)
        public
        view
        priceNotStale
        returns (uint)
    {
        return safeMul_dec(hav_dec, price);
    }
    function USDtoHAV(uint usd_dec)
        public
        view
        priceNotStale
        returns (uint)
    {
        return safeDiv_dec(usd_dec, price);
    }
    function updatePrice(uint newPrice, uint timeSent)
        external
        onlyOracle   
    {
        require(lastPriceUpdateTime < timeSent && timeSent < now + ORACLE_FUTURE_LIMIT,
            "Time sent must be bigger than the last update, and must be less than now + ORACLE_FUTURE_LIMIT");
        price = newPrice;
        lastPriceUpdateTime = timeSent;
        emitPriceUpdated(newPrice, timeSent);
        rolloverFeePeriodIfElapsed();
    }
    function priceIsStale()
        public
        view
        returns (bool)
    {
        return safeAdd(lastPriceUpdateTime, priceStalePeriod) < now;
    }
    modifier requireIssuer(address account)
    {
        require(isIssuer[account], "Must be issuer to perform this action");
        _;
    }
    modifier onlyOracle
    {
        require(msg.sender == oracle, "Must be oracle to perform this action");
        _;
    }
    modifier priceNotStale
    {
        require(!priceIsStale(), "Price must not be stale to perform this action");
        _;
    }
    event PriceUpdated(uint newPrice, uint timestamp);
    bytes32 constant PRICEUPDATED_SIG = keccak256("PriceUpdated(uint256,uint256)");
    function emitPriceUpdated(uint newPrice, uint timestamp) internal {
        proxy._emit(abi.encode(newPrice, timestamp), 1, PRICEUPDATED_SIG, 0, 0, 0);
    }
    event IssuanceRatioUpdated(uint newRatio);
    bytes32 constant ISSUANCERATIOUPDATED_SIG = keccak256("IssuanceRatioUpdated(uint256)");
    function emitIssuanceRatioUpdated(uint newRatio) internal {
        proxy._emit(abi.encode(newRatio), 1, ISSUANCERATIOUPDATED_SIG, 0, 0, 0);
    }
    event FeePeriodRollover(uint timestamp);
    bytes32 constant FEEPERIODROLLOVER_SIG = keccak256("FeePeriodRollover(uint256)");
    function emitFeePeriodRollover(uint timestamp) internal {
        proxy._emit(abi.encode(timestamp), 1, FEEPERIODROLLOVER_SIG, 0, 0, 0);
    } 
    event FeePeriodDurationUpdated(uint duration);
    bytes32 constant FEEPERIODDURATIONUPDATED_SIG = keccak256("FeePeriodDurationUpdated(uint256)");
    function emitFeePeriodDurationUpdated(uint duration) internal {
        proxy._emit(abi.encode(duration), 1, FEEPERIODDURATIONUPDATED_SIG, 0, 0, 0);
    } 
    event FeesWithdrawn(address indexed account, uint value);
    bytes32 constant FEESWITHDRAWN_SIG = keccak256("FeesWithdrawn(address,uint256)");
    function emitFeesWithdrawn(address account, uint value) internal {
        proxy._emit(abi.encode(value), 2, FEESWITHDRAWN_SIG, bytes32(account), 0, 0);
    }
    event OracleUpdated(address newOracle);
    bytes32 constant ORACLEUPDATED_SIG = keccak256("OracleUpdated(address)");
    function emitOracleUpdated(address newOracle) internal {
        proxy._emit(abi.encode(newOracle), 1, ORACLEUPDATED_SIG, 0, 0, 0);
    }
    event NominUpdated(address newNomin);
    bytes32 constant NOMINUPDATED_SIG = keccak256("NominUpdated(address)");
    function emitNominUpdated(address newNomin) internal {
        proxy._emit(abi.encode(newNomin), 1, NOMINUPDATED_SIG, 0, 0, 0);
    }
    event EscrowUpdated(address newEscrow);
    bytes32 constant ESCROWUPDATED_SIG = keccak256("EscrowUpdated(address)");
    function emitEscrowUpdated(address newEscrow) internal {
        proxy._emit(abi.encode(newEscrow), 1, ESCROWUPDATED_SIG, 0, 0, 0);
    }
    event IssuersUpdated(address indexed account, bool indexed value);
    bytes32 constant ISSUERSUPDATED_SIG = keccak256("IssuersUpdated(address,bool)");
    function emitIssuersUpdated(address account, bool value) internal {
        proxy._emit(abi.encode(), 3, ISSUERSUPDATED_SIG, bytes32(account), bytes32(value ? 1 : 0), 0);
    }
}
