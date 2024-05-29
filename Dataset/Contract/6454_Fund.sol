contract Fund is DSMath, DBC, Owned, Shares, FundInterface {
    event OrderUpdated(address exchange, bytes32 orderId, UpdateType updateType);
    struct Modules {  
        CanonicalPriceFeed pricefeed;  
        ComplianceInterface compliance;  
        RiskMgmtInterface riskmgmt;  
    }
    struct Calculations {  
        uint gav;  
        uint managementFee;  
        uint performanceFee;  
        uint unclaimedFees;  
        uint nav;  
        uint highWaterMark;  
        uint totalSupply;  
        uint timestamp;  
    }
    enum UpdateType { make, take, cancel }
    enum RequestStatus { active, cancelled, executed }
    struct Request {  
        address participant;  
        RequestStatus status;  
        address requestAsset;  
        uint shareQuantity;  
        uint giveQuantity;  
        uint receiveQuantity;  
        uint timestamp;      
        uint atUpdateId;     
    }
    struct Exchange {
        address exchange;
        address exchangeAdapter;
        bool takesCustody;   
    }
    struct OpenMakeOrder {
        uint id;  
        uint expiresAt;  
    }
    struct Order {  
        address exchangeAddress;  
        bytes32 orderId;  
        UpdateType updateType;  
        address makerAsset;  
        address takerAsset;  
        uint makerQuantity;  
        uint takerQuantity;  
        uint timestamp;  
        uint fillTakerQuantity;  
    }
    uint public constant MAX_FUND_ASSETS = 20;  
    uint public constant ORDER_EXPIRATION_TIME = 86400;  
    uint public MANAGEMENT_FEE_RATE;  
    uint public PERFORMANCE_FEE_RATE;  
    address public VERSION;  
    Asset public QUOTE_ASSET;  
    Modules public modules;  
    Exchange[] public exchanges;  
    Calculations public atLastUnclaimedFeeAllocation;  
    Order[] public orders;   
    mapping (address => mapping(address => OpenMakeOrder)) public exchangesToOpenMakeOrders;  
    bool public isShutDown;  
    Request[] public requests;  
    mapping (address => bool) public isInvestAllowed;  
    address[] public ownedAssets;  
    mapping (address => bool) public isInAssetList;  
    mapping (address => bool) public isInOpenMakeOrder;  
    function Fund(
        address ofManager,
        bytes32 withName,
        address ofQuoteAsset,
        uint ofManagementFee,
        uint ofPerformanceFee,
        address ofCompliance,
        address ofRiskMgmt,
        address ofPriceFeed,
        address[] ofExchanges,
        address[] ofDefaultAssets
    )
        Shares(withName, "MLNF", 18, now)
    {
        require(ofManagementFee < 10 ** 18);  
        require(ofPerformanceFee < 10 ** 18);  
        isInvestAllowed[ofQuoteAsset] = true;
        owner = ofManager;
        MANAGEMENT_FEE_RATE = ofManagementFee;  
        PERFORMANCE_FEE_RATE = ofPerformanceFee;  
        VERSION = msg.sender;
        modules.compliance = ComplianceInterface(ofCompliance);
        modules.riskmgmt = RiskMgmtInterface(ofRiskMgmt);
        modules.pricefeed = CanonicalPriceFeed(ofPriceFeed);
        for (uint i = 0; i < ofExchanges.length; ++i) {
            require(modules.pricefeed.exchangeIsRegistered(ofExchanges[i]));
            var (ofExchangeAdapter, takesCustody, ) = modules.pricefeed.getExchangeInformation(ofExchanges[i]);
            exchanges.push(Exchange({
                exchange: ofExchanges[i],
                exchangeAdapter: ofExchangeAdapter,
                takesCustody: takesCustody
            }));
        }
        QUOTE_ASSET = Asset(ofQuoteAsset);
        ownedAssets.push(ofQuoteAsset);
        isInAssetList[ofQuoteAsset] = true;
        require(address(QUOTE_ASSET) == modules.pricefeed.getQuoteAsset());  
        for (uint j = 0; j < ofDefaultAssets.length; j++) {
            require(modules.pricefeed.assetIsRegistered(ofDefaultAssets[j]));
            isInvestAllowed[ofDefaultAssets[j]] = true;
        }
        atLastUnclaimedFeeAllocation = Calculations({
            gav: 0,
            managementFee: 0,
            performanceFee: 0,
            unclaimedFees: 0,
            nav: 0,
            highWaterMark: 10 ** getDecimals(),
            totalSupply: _totalSupply,
            timestamp: now
        });
    }
    function enableInvestment(address[] ofAssets)
        external
        pre_cond(isOwner())
    {
        for (uint i = 0; i < ofAssets.length; ++i) {
            require(modules.pricefeed.assetIsRegistered(ofAssets[i]));
            isInvestAllowed[ofAssets[i]] = true;
        }
    }
    function disableInvestment(address[] ofAssets)
        external
        pre_cond(isOwner())
    {
        for (uint i = 0; i < ofAssets.length; ++i) {
            isInvestAllowed[ofAssets[i]] = false;
        }
    }
    function shutDown() external pre_cond(msg.sender == VERSION) { isShutDown = true; }
    function requestInvestment(
        uint giveQuantity,
        uint shareQuantity,
        address investmentAsset
    )
        external
        pre_cond(!isShutDown)
        pre_cond(isInvestAllowed[investmentAsset])  
        pre_cond(modules.compliance.isInvestmentPermitted(msg.sender, giveQuantity, shareQuantity))     
    {
        requests.push(Request({
            participant: msg.sender,
            status: RequestStatus.active,
            requestAsset: investmentAsset,
            shareQuantity: shareQuantity,
            giveQuantity: giveQuantity,
            receiveQuantity: shareQuantity,
            timestamp: now,
            atUpdateId: modules.pricefeed.getLastUpdateId()
        }));
        emit RequestUpdated(getLastRequestId());
    }
    function executeRequest(uint id)
        external
        pre_cond(!isShutDown)
        pre_cond(requests[id].status == RequestStatus.active)
        pre_cond(
            _totalSupply == 0 ||
            (
                now >= add(requests[id].timestamp, modules.pricefeed.getInterval()) &&
                modules.pricefeed.getLastUpdateId() >= add(requests[id].atUpdateId, 2)
            )
        )    
    {
        Request request = requests[id];
        var (isRecent, , ) =
            modules.pricefeed.getPriceInfo(address(request.requestAsset));
        require(isRecent);
        uint costQuantity = toWholeShareUnit(mul(request.shareQuantity, calcSharePriceAndAllocateFees()));  
        if (request.requestAsset != address(QUOTE_ASSET)) {
            var (isPriceRecent, invertedRequestAssetPrice, requestAssetDecimal) = modules.pricefeed.getInvertedPriceInfo(request.requestAsset);
            if (!isPriceRecent) {
                revert();
            }
            costQuantity = mul(costQuantity, invertedRequestAssetPrice) / 10 ** requestAssetDecimal;
        }
        if (
            isInvestAllowed[request.requestAsset] &&
            costQuantity <= request.giveQuantity
        ) {
            request.status = RequestStatus.executed;
            require(AssetInterface(request.requestAsset).transferFrom(request.participant, address(this), costQuantity));  
            createShares(request.participant, request.shareQuantity);  
            if (!isInAssetList[request.requestAsset]) {
                ownedAssets.push(request.requestAsset);
                isInAssetList[request.requestAsset] = true;
            }
        } else {
            revert();  
        }
    }
    function cancelRequest(uint id)
        external
        pre_cond(requests[id].status == RequestStatus.active)  
        pre_cond(requests[id].participant == msg.sender || isShutDown)  
    {
        requests[id].status = RequestStatus.cancelled;
    }
    function redeemAllOwnedAssets(uint shareQuantity)
        external
        returns (bool success)
    {
        return emergencyRedeem(shareQuantity, ownedAssets);
    }
    function callOnExchange(
        uint exchangeIndex,
        bytes4 method,
        address[5] orderAddresses,
        uint[8] orderValues,
        bytes32 identifier,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
    {
        require(
            modules.pricefeed.exchangeMethodIsAllowed(
                exchanges[exchangeIndex].exchange, method
            )
        );
        require(
            exchanges[exchangeIndex].exchangeAdapter.delegatecall(
                method, exchanges[exchangeIndex].exchange,
                orderAddresses, orderValues, identifier, v, r, s
            )
        );
    }
    function addOpenMakeOrder(
        address ofExchange,
        address ofSellAsset,
        uint orderId
    )
        pre_cond(msg.sender == address(this))
    {
        isInOpenMakeOrder[ofSellAsset] = true;
        exchangesToOpenMakeOrders[ofExchange][ofSellAsset].id = orderId;
        exchangesToOpenMakeOrders[ofExchange][ofSellAsset].expiresAt = add(now, ORDER_EXPIRATION_TIME);
    }
    function removeOpenMakeOrder(
        address ofExchange,
        address ofSellAsset
    )
        pre_cond(msg.sender == address(this))
    {
        delete exchangesToOpenMakeOrders[ofExchange][ofSellAsset];
    }
    function orderUpdateHook(
        address ofExchange,
        bytes32 orderId,
        UpdateType updateType,
        address[2] orderAddresses,  
        uint[3] orderValues         
    )
        pre_cond(msg.sender == address(this))
    {
        if (updateType == UpdateType.make || updateType == UpdateType.take) {
            orders.push(Order({
                exchangeAddress: ofExchange,
                orderId: orderId,
                updateType: updateType,
                makerAsset: orderAddresses[0],
                takerAsset: orderAddresses[1],
                makerQuantity: orderValues[0],
                takerQuantity: orderValues[1],
                timestamp: block.timestamp,
                fillTakerQuantity: orderValues[2]
            }));
        }
        emit OrderUpdated(ofExchange, orderId, updateType);
    }
    function calcGav() returns (uint gav) {
        uint[] memory allAssetHoldings = new uint[](ownedAssets.length);
        uint[] memory allAssetPrices = new uint[](ownedAssets.length);
        address[] memory tempOwnedAssets;
        tempOwnedAssets = ownedAssets;
        delete ownedAssets;
        for (uint i = 0; i < tempOwnedAssets.length; ++i) {
            address ofAsset = tempOwnedAssets[i];
            uint assetHoldings = add(
                uint(AssetInterface(ofAsset).balanceOf(address(this))),  
                quantityHeldInCustodyOfExchange(ofAsset)
            );
            var (isRecent, assetPrice, assetDecimals) = modules.pricefeed.getPriceInfo(ofAsset);
            if (!isRecent) {
                revert();
            }
            allAssetHoldings[i] = assetHoldings;
            allAssetPrices[i] = assetPrice;
            gav = add(gav, mul(assetHoldings, assetPrice) / (10 ** uint256(assetDecimals)));    
            if (assetHoldings != 0 || ofAsset == address(QUOTE_ASSET) || isInOpenMakeOrder[ofAsset]) {  
                ownedAssets.push(ofAsset);
            } else {
                isInAssetList[ofAsset] = false;  
            }
        }
        emit PortfolioContent(tempOwnedAssets, allAssetHoldings, allAssetPrices);
    }
    function addAssetToOwnedAssets (address ofAsset)
        public
        pre_cond(isOwner() || msg.sender == address(this))
    {
        isInOpenMakeOrder[ofAsset] = true;
        if (!isInAssetList[ofAsset]) {
            ownedAssets.push(ofAsset);
            isInAssetList[ofAsset] = true;
        }
    }
    function calcUnclaimedFees(uint gav)
        view
        returns (
            uint managementFee,
            uint performanceFee,
            uint unclaimedFees)
    {
        uint timePassed = sub(now, atLastUnclaimedFeeAllocation.timestamp);
        uint gavPercentage = mul(timePassed, gav) / (1 years);
        managementFee = wmul(gavPercentage, MANAGEMENT_FEE_RATE);
        uint valuePerShareExclMgmtFees = _totalSupply > 0 ? calcValuePerShare(sub(gav, managementFee), _totalSupply) : toSmallestShareUnit(1);
        if (valuePerShareExclMgmtFees > atLastUnclaimedFeeAllocation.highWaterMark) {
            uint gainInSharePrice = sub(valuePerShareExclMgmtFees, atLastUnclaimedFeeAllocation.highWaterMark);
            uint investmentProfits = wmul(gainInSharePrice, _totalSupply);
            performanceFee = wmul(investmentProfits, PERFORMANCE_FEE_RATE);
        }
        unclaimedFees = add(managementFee, performanceFee);
    }
    function calcNav(uint gav, uint unclaimedFees)
        view
        returns (uint nav)
    {
        nav = sub(gav, unclaimedFees);
    }
    function calcValuePerShare(uint totalValue, uint numShares)
        view
        pre_cond(numShares > 0)
        returns (uint valuePerShare)
    {
        valuePerShare = toSmallestShareUnit(totalValue) / numShares;
    }
    function performCalculations()
        view
        returns (
            uint gav,
            uint managementFee,
            uint performanceFee,
            uint unclaimedFees,
            uint feesShareQuantity,
            uint nav,
            uint sharePrice
        )
    {
        gav = calcGav();  
        (managementFee, performanceFee, unclaimedFees) = calcUnclaimedFees(gav);
        nav = calcNav(gav, unclaimedFees);
        feesShareQuantity = (gav == 0) ? 0 : mul(_totalSupply, unclaimedFees) / gav;
        uint totalSupplyAccountingForFees = add(_totalSupply, feesShareQuantity);
        sharePrice = _totalSupply > 0 ? calcValuePerShare(gav, totalSupplyAccountingForFees) : toSmallestShareUnit(1);  
    }
    function calcSharePriceAndAllocateFees() public returns (uint)
    {
        var (
            gav,
            managementFee,
            performanceFee,
            unclaimedFees,
            feesShareQuantity,
            nav,
            sharePrice
        ) = performCalculations();
        createShares(owner, feesShareQuantity);  
        uint highWaterMark = atLastUnclaimedFeeAllocation.highWaterMark >= sharePrice ? atLastUnclaimedFeeAllocation.highWaterMark : sharePrice;
        atLastUnclaimedFeeAllocation = Calculations({
            gav: gav,
            managementFee: managementFee,
            performanceFee: performanceFee,
            unclaimedFees: unclaimedFees,
            nav: nav,
            highWaterMark: highWaterMark,
            totalSupply: _totalSupply,
            timestamp: now
        });
        emit FeesConverted(now, feesShareQuantity, unclaimedFees);
        emit CalculationUpdate(now, managementFee, performanceFee, nav, sharePrice, _totalSupply);
        return sharePrice;
    }
    function emergencyRedeem(uint shareQuantity, address[] requestedAssets)
        public
        pre_cond(balances[msg.sender] >= shareQuantity)   
        returns (bool)
    {
        address ofAsset;
        uint[] memory ownershipQuantities = new uint[](requestedAssets.length);
        address[] memory redeemedAssets = new address[](requestedAssets.length);
        for (uint i = 0; i < requestedAssets.length; ++i) {
            ofAsset = requestedAssets[i];
            require(isInAssetList[ofAsset]);
            for (uint j = 0; j < redeemedAssets.length; j++) {
                if (ofAsset == redeemedAssets[j]) {
                    revert();
                }
            }
            redeemedAssets[i] = ofAsset;
            uint assetHoldings = add(
                uint(AssetInterface(ofAsset).balanceOf(address(this))),
                quantityHeldInCustodyOfExchange(ofAsset)
            );
            if (assetHoldings == 0) continue;
            ownershipQuantities[i] = mul(assetHoldings, shareQuantity) / _totalSupply;
            if (uint(AssetInterface(ofAsset).balanceOf(address(this))) < ownershipQuantities[i]) {
                isShutDown = true;
                emit ErrorMessage("CRITICAL ERR: Not enough assetHoldings for owed ownershipQuantitiy");
                return false;
            }
        }
        annihilateShares(msg.sender, shareQuantity);
        for (uint k = 0; k < requestedAssets.length; ++k) {
            ofAsset = requestedAssets[k];
            if (ownershipQuantities[k] == 0) {
                continue;
            } else if (!AssetInterface(ofAsset).transfer(msg.sender, ownershipQuantities[k])) {
                revert();
            }
        }
        emit Redeemed(msg.sender, now, shareQuantity);
        return true;
    }
    function quantityHeldInCustodyOfExchange(address ofAsset) returns (uint) {
        uint totalSellQuantity;      
        uint totalSellQuantityInApprove;  
        for (uint i; i < exchanges.length; i++) {
            if (exchangesToOpenMakeOrders[exchanges[i].exchange][ofAsset].id == 0) {
                continue;
            }
            var (sellAsset, , sellQuantity, ) = GenericExchangeInterface(exchanges[i].exchangeAdapter).getOrder(exchanges[i].exchange, exchangesToOpenMakeOrders[exchanges[i].exchange][ofAsset].id);
            if (sellQuantity == 0) {     
                delete exchangesToOpenMakeOrders[exchanges[i].exchange][ofAsset];
            }
            totalSellQuantity = add(totalSellQuantity, sellQuantity);
            if (!exchanges[i].takesCustody) {
                totalSellQuantityInApprove += sellQuantity;
            }
        }
        if (totalSellQuantity == 0) {
            isInOpenMakeOrder[sellAsset] = false;
        }
        return sub(totalSellQuantity, totalSellQuantityInApprove);  
    }
    function calcSharePrice() view returns (uint sharePrice) {
        (, , , , , sharePrice) = performCalculations();
        return sharePrice;
    }
    function getModules() view returns (address, address, address) {
        return (
            address(modules.pricefeed),
            address(modules.compliance),
            address(modules.riskmgmt)
        );
    }
    function getLastRequestId() view returns (uint) { return requests.length - 1; }
    function getLastOrderIndex() view returns (uint) { return orders.length - 1; }
    function getManager() view returns (address) { return owner; }
    function getOwnedAssetsLength() view returns (uint) { return ownedAssets.length; }
    function getExchangeInfo() view returns (address[], address[], bool[]) {
        address[] memory ofExchanges = new address[](exchanges.length);
        address[] memory ofAdapters = new address[](exchanges.length);
        bool[] memory takesCustody = new bool[](exchanges.length);
        for (uint i = 0; i < exchanges.length; i++) {
            ofExchanges[i] = exchanges[i].exchange;
            ofAdapters[i] = exchanges[i].exchangeAdapter;
            takesCustody[i] = exchanges[i].takesCustody;
        }
        return (ofExchanges, ofAdapters, takesCustody);
    }
    function orderExpired(address ofExchange, address ofAsset) view returns (bool) {
        uint expiryTime = exchangesToOpenMakeOrders[ofExchange][ofAsset].expiresAt;
        require(expiryTime > 0);
        return block.timestamp >= expiryTime;
    }
    function getOpenOrderInfo(address ofExchange, address ofAsset) view returns (uint, uint) {
        OpenMakeOrder order = exchangesToOpenMakeOrders[ofExchange][ofAsset];
        return (order.id, order.expiresAt);
    }
}
