contract Fund is DSMath, DBC, Owned, RestrictedShares, FundInterface, ERC223ReceivingContract {
    struct Modules {  
        PriceFeedInterface pricefeed;  
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
    enum RequestStatus { active, cancelled, executed }
    enum RequestType { invest, redeem, tokenFallbackRedeem }
    struct Request {  
        address participant;  
        RequestStatus status;  
        RequestType requestType;  
        address requestAsset;  
        uint shareQuantity;  
        uint giveQuantity;  
        uint receiveQuantity;  
        uint timestamp;      
        uint atUpdateId;     
    }
    enum OrderStatus { active, partiallyFilled, fullyFilled, cancelled }
    enum OrderType { make, take }
    struct Order {  
        uint exchangeId;  
        OrderStatus status;  
        OrderType orderType;  
        address sellAsset;  
        address buyAsset;  
        uint sellQuantity;  
        uint buyQuantity;  
        uint timestamp;  
        uint fillQuantity;  
    }
    struct Exchange {
        address exchange;  
        ExchangeInterface exchangeAdapter;  
        bool isApproveOnly;  
    }
    uint public constant MAX_FUND_ASSETS = 4;  
    uint public MANAGEMENT_FEE_RATE;  
    uint public PERFORMANCE_FEE_RATE;  
    address public VERSION;  
    Asset public QUOTE_ASSET;  
    NativeAssetInterface public NATIVE_ASSET;  
    Modules public module;  
    Exchange[] public exchanges;  
    Calculations public atLastUnclaimedFeeAllocation;  
    bool public isShutDown;  
    Request[] public requests;  
    bool public isInvestAllowed;  
    bool public isRedeemAllowed;  
    Order[] public orders;  
    mapping (uint => mapping(address => uint)) public exchangeIdsToOpenMakeOrderIds;  
    address[] public ownedAssets;  
    mapping (address => bool) public isInAssetList;  
    mapping (address => bool) public isInOpenMakeOrder;  
    function Fund(
        address ofManager,
        string withName,
        address ofQuoteAsset,
        uint ofManagementFee,
        uint ofPerformanceFee,
        address ofNativeAsset,
        address ofCompliance,
        address ofRiskMgmt,
        address ofPriceFeed,
        address[] ofExchanges,
        address[] ofExchangeAdapters
    )
        RestrictedShares(withName, "MLNF", 18, now)
    {
        isInvestAllowed = true;
        isRedeemAllowed = true;
        owner = ofManager;
        require(ofManagementFee < 10 ** 18);  
        MANAGEMENT_FEE_RATE = ofManagementFee;  
        require(ofPerformanceFee < 10 ** 18);  
        PERFORMANCE_FEE_RATE = ofPerformanceFee;  
        VERSION = msg.sender;
        module.compliance = ComplianceInterface(ofCompliance);
        module.riskmgmt = RiskMgmtInterface(ofRiskMgmt);
        module.pricefeed = PriceFeedInterface(ofPriceFeed);
        for (uint i = 0; i < ofExchanges.length; ++i) {
            ExchangeInterface adapter = ExchangeInterface(ofExchangeAdapters[i]);
            bool isApproveOnly = adapter.isApproveOnly();
            exchanges.push(Exchange({
                exchange: ofExchanges[i],
                exchangeAdapter: adapter,
                isApproveOnly: isApproveOnly
            }));
        }
        QUOTE_ASSET = Asset(ofQuoteAsset);
        NATIVE_ASSET = NativeAssetInterface(ofNativeAsset);
        ownedAssets.push(ofQuoteAsset);
        isInAssetList[ofQuoteAsset] = true;
        ownedAssets.push(ofNativeAsset);
        isInAssetList[ofNativeAsset] = true;
        require(address(QUOTE_ASSET) == module.pricefeed.getQuoteAsset());  
        atLastUnclaimedFeeAllocation = Calculations({
            gav: 0,
            managementFee: 0,
            performanceFee: 0,
            unclaimedFees: 0,
            nav: 0,
            highWaterMark: 10 ** getDecimals(),
            totalSupply: totalSupply,
            timestamp: now
        });
    }
    function enableInvestment() external pre_cond(isOwner()) { isInvestAllowed = true; }
    function disableInvestment() external pre_cond(isOwner()) { isInvestAllowed = false; }
    function enableRedemption() external pre_cond(isOwner()) { isRedeemAllowed = true; }
    function disableRedemption() external pre_cond(isOwner()) { isRedeemAllowed = false; }
    function shutDown() external pre_cond(msg.sender == VERSION) { isShutDown = true; }
    function requestInvestment(
        uint giveQuantity,
        uint shareQuantity,
        bool isNativeAsset
    )
        external
        pre_cond(!isShutDown)
        pre_cond(isInvestAllowed)  
        pre_cond(module.compliance.isInvestmentPermitted(msg.sender, giveQuantity, shareQuantity))     
    {
        requests.push(Request({
            participant: msg.sender,
            status: RequestStatus.active,
            requestType: RequestType.invest,
            requestAsset: isNativeAsset ? address(NATIVE_ASSET) : address(QUOTE_ASSET),
            shareQuantity: shareQuantity,
            giveQuantity: giveQuantity,
            receiveQuantity: shareQuantity,
            timestamp: now,
            atUpdateId: module.pricefeed.getLastUpdateId()
        }));
        RequestUpdated(getLastRequestId());
    }
    function requestRedemption(
        uint shareQuantity,
        uint receiveQuantity,
        bool isNativeAsset
      )
        external
        pre_cond(!isShutDown)
        pre_cond(isRedeemAllowed)  
        pre_cond(module.compliance.isRedemptionPermitted(msg.sender, shareQuantity, receiveQuantity))  
    {
        requests.push(Request({
            participant: msg.sender,
            status: RequestStatus.active,
            requestType: RequestType.redeem,
            requestAsset: isNativeAsset ? address(NATIVE_ASSET) : address(QUOTE_ASSET),
            shareQuantity: shareQuantity,
            giveQuantity: shareQuantity,
            receiveQuantity: receiveQuantity,
            timestamp: now,
            atUpdateId: module.pricefeed.getLastUpdateId()
        }));
        RequestUpdated(getLastRequestId());
    }
    function executeRequest(uint id)
        external
        pre_cond(!isShutDown)
        pre_cond(requests[id].status == RequestStatus.active)
        pre_cond(requests[id].requestType != RequestType.redeem || requests[id].shareQuantity <= balances[requests[id].participant])  
        pre_cond(
            totalSupply == 0 ||
            (
                now >= add(requests[id].timestamp, module.pricefeed.getInterval()) &&
                module.pricefeed.getLastUpdateId() >= add(requests[id].atUpdateId, 2)
            )
        )    
    {
        Request request = requests[id];
        require(module.pricefeed.hasRecentPrice(address(request.requestAsset)));
        uint costQuantity = toWholeShareUnit(mul(request.shareQuantity, calcSharePriceAndAllocateFees()));  
        if (request.requestAsset == address(NATIVE_ASSET)) {
            var (isPriceRecent, invertedNativeAssetPrice, nativeAssetDecimal) = module.pricefeed.getInvertedPrice(address(NATIVE_ASSET));
            if (!isPriceRecent) {
                revert();
            }
            costQuantity = mul(costQuantity, invertedNativeAssetPrice) / 10 ** nativeAssetDecimal;
        }
        if (
            isInvestAllowed &&
            request.requestType == RequestType.invest &&
            costQuantity <= request.giveQuantity
        ) {
            request.status = RequestStatus.executed;
            assert(AssetInterface(request.requestAsset).transferFrom(request.participant, this, costQuantity));  
            createShares(request.participant, request.shareQuantity);  
        } else if (
            isRedeemAllowed &&
            request.requestType == RequestType.redeem &&
            request.receiveQuantity <= costQuantity
        ) {
            request.status = RequestStatus.executed;
            assert(AssetInterface(request.requestAsset).transfer(request.participant, costQuantity));  
            annihilateShares(request.participant, request.shareQuantity);  
        } else if (
            isRedeemAllowed &&
            request.requestType == RequestType.tokenFallbackRedeem &&
            request.receiveQuantity <= costQuantity
        ) {
            request.status = RequestStatus.executed;
            assert(AssetInterface(request.requestAsset).transfer(request.participant, costQuantity));  
            annihilateShares(this, request.shareQuantity);  
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
    function makeOrder(
        uint exchangeNumber,
        address sellAsset,
        address buyAsset,
        uint sellQuantity,
        uint buyQuantity
    )
        external
        pre_cond(isOwner())
        pre_cond(!isShutDown)
    {
        require(buyAsset != address(this));  
        require(quantityHeldInCustodyOfExchange(sellAsset) == 0);  
        require(module.pricefeed.existsPriceOnAssetPair(sellAsset, buyAsset));  
        var (isRecent, referencePrice, ) = module.pricefeed.getReferencePrice(sellAsset, buyAsset);
        require(isRecent);   
        require(
            module.riskmgmt.isMakePermitted(
                module.pricefeed.getOrderPrice(
                    sellAsset,
                    buyAsset,
                    sellQuantity,
                    buyQuantity
                ),
                referencePrice,
                sellAsset,
                buyAsset,
                sellQuantity,
                buyQuantity
            )
        );  
        require(isInAssetList[buyAsset] || ownedAssets.length < MAX_FUND_ASSETS);  
        require(AssetInterface(sellAsset).approve(exchanges[exchangeNumber].exchange, sellQuantity));  
        require(address(exchanges[exchangeNumber].exchangeAdapter).delegatecall(bytes4(keccak256("makeOrder(address,address,address,uint256,uint256)")), exchanges[exchangeNumber].exchange, sellAsset, buyAsset, sellQuantity, buyQuantity));
        exchangeIdsToOpenMakeOrderIds[exchangeNumber][sellAsset] = exchanges[exchangeNumber].exchangeAdapter.getLastOrderId(exchanges[exchangeNumber].exchange);
        require(exchangeIdsToOpenMakeOrderIds[exchangeNumber][sellAsset] != 0);
        isInOpenMakeOrder[buyAsset] = true;
        if (!isInAssetList[buyAsset]) {
            ownedAssets.push(buyAsset);
            isInAssetList[buyAsset] = true;
        }
        orders.push(Order({
            exchangeId: exchangeIdsToOpenMakeOrderIds[exchangeNumber][sellAsset],
            status: OrderStatus.active,
            orderType: OrderType.make,
            sellAsset: sellAsset,
            buyAsset: buyAsset,
            sellQuantity: sellQuantity,
            buyQuantity: buyQuantity,
            timestamp: now,
            fillQuantity: 0
        }));
        OrderUpdated(exchangeIdsToOpenMakeOrderIds[exchangeNumber][sellAsset]);
    }
    function takeOrder(uint exchangeNumber, uint id, uint receiveQuantity)
        external
        pre_cond(isOwner())
        pre_cond(!isShutDown)
    {
        Order memory order;  
        (
            order.sellAsset,
            order.buyAsset,
            order.sellQuantity,
            order.buyQuantity
        ) = exchanges[exchangeNumber].exchangeAdapter.getOrder(exchanges[exchangeNumber].exchange, id);
        require(order.sellAsset != address(this));  
        require(module.pricefeed.existsPriceOnAssetPair(order.buyAsset, order.sellAsset));  
        require(isInAssetList[order.sellAsset] || ownedAssets.length < MAX_FUND_ASSETS);  
        var (isRecent, referencePrice, ) = module.pricefeed.getReferencePrice(order.buyAsset, order.sellAsset);
        require(isRecent);  
        require(receiveQuantity <= order.sellQuantity);  
        uint spendQuantity = mul(receiveQuantity, order.buyQuantity) / order.sellQuantity;
        require(AssetInterface(order.buyAsset).approve(exchanges[exchangeNumber].exchange, spendQuantity));  
        require(
            module.riskmgmt.isTakePermitted(
            module.pricefeed.getOrderPrice(
                order.buyAsset,
                order.sellAsset,
                order.buyQuantity,  
                order.sellQuantity  
            ),
            referencePrice,
            order.buyAsset,
            order.sellAsset,
            order.buyQuantity,
            order.sellQuantity
        ));  
        require(address(exchanges[exchangeNumber].exchangeAdapter).delegatecall(bytes4(keccak256("takeOrder(address,uint256,uint256)")), exchanges[exchangeNumber].exchange, id, receiveQuantity));
        if (!isInAssetList[order.sellAsset]) {
            ownedAssets.push(order.sellAsset);
            isInAssetList[order.sellAsset] = true;
        }
        order.exchangeId = id;
        order.status = OrderStatus.fullyFilled;
        order.orderType = OrderType.take;
        order.timestamp = now;
        order.fillQuantity = receiveQuantity;
        orders.push(order);
        OrderUpdated(id);
    }
    function cancelOrder(uint exchangeNumber, uint id)
        external
        pre_cond(isOwner() || isShutDown)
    {
        Order order = orders[id];
        require(address(exchanges[exchangeNumber].exchangeAdapter).delegatecall(bytes4(keccak256("cancelOrder(address,uint256)")), exchanges[exchangeNumber].exchange, order.exchangeId));
        order.status = OrderStatus.cancelled;
        OrderUpdated(id);
    }
    function tokenFallback(
        address ofSender,
        uint tokenAmount,
        bytes metadata
    ) {
        if (msg.sender != address(this)) {
            for (uint i; i < exchanges.length; i++) {
                if (exchanges[i].exchange == ofSender) return;  
            }
            revert();
        } else {     
            requests.push(Request({
                participant: ofSender,
                status: RequestStatus.active,
                requestType: RequestType.tokenFallbackRedeem,
                requestAsset: address(QUOTE_ASSET),  
                shareQuantity: tokenAmount,
                giveQuantity: tokenAmount,               
                receiveQuantity: 0,           
                timestamp: now,
                atUpdateId: module.pricefeed.getLastUpdateId()
            }));
            RequestUpdated(getLastRequestId());
        }
    }
    function calcGav() returns (uint gav) {
        address[] memory tempOwnedAssets;  
        tempOwnedAssets = ownedAssets;
        delete ownedAssets;
        for (uint i = 0; i < tempOwnedAssets.length; ++i) {
            address ofAsset = tempOwnedAssets[i];
            uint assetHoldings = add(
                uint(AssetInterface(ofAsset).balanceOf(this)),  
                quantityHeldInCustodyOfExchange(ofAsset)
            );
            var (isRecent, assetPrice, assetDecimals) = module.pricefeed.getPrice(ofAsset);
            if (!isRecent) {
                revert();
            }
            gav = add(gav, mul(assetHoldings, assetPrice) / (10 ** uint256(assetDecimals)));    
            if (assetHoldings != 0 || ofAsset == address(QUOTE_ASSET) || ofAsset == address(NATIVE_ASSET) || isInOpenMakeOrder[ofAsset]) {  
                ownedAssets.push(ofAsset);
            } else {
                isInAssetList[ofAsset] = false;  
            }
            PortfolioContent(assetHoldings, assetPrice, assetDecimals);
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
        uint valuePerShareExclMgmtFees = totalSupply > 0 ? calcValuePerShare(sub(gav, managementFee), totalSupply) : toSmallestShareUnit(1);
        if (valuePerShareExclMgmtFees > atLastUnclaimedFeeAllocation.highWaterMark) {
            uint gainInSharePrice = sub(valuePerShareExclMgmtFees, atLastUnclaimedFeeAllocation.highWaterMark);
            uint investmentProfits = wmul(gainInSharePrice, totalSupply);
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
        feesShareQuantity = (gav == 0) ? 0 : mul(totalSupply, unclaimedFees) / gav;
        uint totalSupplyAccountingForFees = add(totalSupply, feesShareQuantity);
        sharePrice = nav > 0 ? calcValuePerShare(gav, totalSupplyAccountingForFees) : toSmallestShareUnit(1);  
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
            totalSupply: totalSupply,
            timestamp: now
        });
        FeesConverted(now, feesShareQuantity, unclaimedFees);
        CalculationUpdate(now, managementFee, performanceFee, nav, sharePrice, totalSupply);
        return sharePrice;
    }
    function emergencyRedeem(uint shareQuantity, address[] requestedAssets)
        public
        pre_cond(balances[msg.sender] >= shareQuantity)   
        returns (bool)
    {
        address ofAsset;
        uint[] memory ownershipQuantities = new uint[](requestedAssets.length);
        for (uint i = 0; i < requestedAssets.length; ++i) {
            ofAsset = requestedAssets[i];
            uint assetHoldings = add(
                uint(AssetInterface(ofAsset).balanceOf(this)),
                quantityHeldInCustodyOfExchange(ofAsset)
            );
            if (assetHoldings == 0) continue;
            ownershipQuantities[i] = mul(assetHoldings, shareQuantity) / totalSupply;
            if (uint(AssetInterface(ofAsset).balanceOf(this)) < ownershipQuantities[i]) {
                isShutDown = true;
                ErrorMessage("CRITICAL ERR: Not enough assetHoldings for owed ownershipQuantitiy");
                return false;
            }
        }
        annihilateShares(msg.sender, shareQuantity);
        for (uint j = 0; j < requestedAssets.length; ++j) {
            ofAsset = requestedAssets[j];
            if (ownershipQuantities[j] == 0) {
                continue;
            } else if (!AssetInterface(ofAsset).transfer(msg.sender, ownershipQuantities[j])) {
                revert();
            }
        }
        Redeemed(msg.sender, now, shareQuantity);
        return true;
    }
    function quantityHeldInCustodyOfExchange(address ofAsset) returns (uint) {
        uint totalSellQuantity;      
        uint totalSellQuantityInApprove;  
        for (uint i; i < exchanges.length; i++) {
            if (exchangeIdsToOpenMakeOrderIds[i][ofAsset] == 0) {
                continue;
            }
            var (sellAsset, , sellQuantity, ) = exchanges[i].exchangeAdapter.getOrder(exchanges[i].exchange, exchangeIdsToOpenMakeOrderIds[i][ofAsset]);
            if (sellQuantity == 0) {
                exchangeIdsToOpenMakeOrderIds[i][ofAsset] = 0;
            }
            totalSellQuantity = add(totalSellQuantity, sellQuantity);
            if (exchanges[i].isApproveOnly) {
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
            address(module.pricefeed),
            address(module.compliance),
            address(module.riskmgmt)
        );
    }
    function getLastOrderId() view returns (uint) { return orders.length - 1; }
    function getLastRequestId() view returns (uint) { return requests.length - 1; }
    function getNameHash() view returns (bytes32) { return bytes32(keccak256(name)); }
    function getManager() view returns (address) { return owner; }
}
