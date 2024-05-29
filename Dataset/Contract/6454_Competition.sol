contract Competition is CompetitionInterface, DSMath, DBC, Owned {
    struct Registrant {
        address fund;  
        address registrant;  
        bool hasSigned;  
        uint buyinQuantity;  
        uint payoutQuantity;  
        bool isRewarded;  
    }
    struct RegistrantId {
        uint id;  
        bool exists;  
    }
    bytes public constant TERMS_AND_CONDITIONS = hex"12208E21FD34B8B2409972D30326D840C9D747438A118580D6BA8C0735ED53810491";
    uint public MELON_BASE_UNIT = 10 ** 18;
    address public custodian;  
    uint public startTime;  
    uint public endTime;  
    uint public payoutRate;  
    uint public bonusRate;  
    uint public totalMaxBuyin;  
    uint public currentTotalBuyin;  
    uint public maxRegistrants;  
    uint public prizeMoneyAsset;  
    uint public prizeMoneyQuantity;  
    address public MELON_ASSET;  
    ERC20Interface public MELON_CONTRACT;  
    address public COMPETITION_VERSION;  
    Registrant[] public registrants;  
    mapping (address => address) public registeredFundToRegistrants;  
    mapping(address => RegistrantId) public registrantToRegistrantIds;  
    mapping(address => uint) public whitelistantToMaxBuyin;  
    event Register(uint withId, address fund, address manager);
    function Competition(
        address ofMelonAsset,
        address ofCompetitionVersion,
        address ofCustodian,
        uint ofStartTime,
        uint ofEndTime,
        uint ofPayoutRate,
        uint ofTotalMaxBuyin,
        uint ofMaxRegistrants
    ) {
        MELON_ASSET = ofMelonAsset;
        MELON_CONTRACT = ERC20Interface(MELON_ASSET);
        COMPETITION_VERSION = ofCompetitionVersion;
        custodian = ofCustodian;
        startTime = ofStartTime;
        endTime = ofEndTime;
        payoutRate = ofPayoutRate;
        totalMaxBuyin = ofTotalMaxBuyin;
        maxRegistrants = ofMaxRegistrants;
    }
    function termsAndConditionsAreSigned(address byManager, uint8 v, bytes32 r, bytes32 s) view returns (bool) {
        return ecrecover(
            keccak256("\x19Ethereum Signed Message:\n34", TERMS_AND_CONDITIONS),
            v,
            r,
            s
        ) == byManager;  
    }
    function isWhitelisted(address x) view returns (bool) { return whitelistantToMaxBuyin[x] > 0; }
    function isCompetitionActive() view returns (bool) { return now >= startTime && now < endTime; }
    function getMelonAsset() view returns (address) { return MELON_ASSET; }
    function getRegistrantId(address x) view returns (uint) { return registrantToRegistrantIds[x].id; }
    function getRegistrantFund(address x) view returns (address) { return registrants[getRegistrantId(x)].fund; }
    function getTimeTillEnd() view returns (uint) {
        if (now > endTime) {
            return 0;
        }
        return sub(endTime, now);
    }
    function getEtherValue(uint amount) view returns (uint) {
        address feedAddress = Version(COMPETITION_VERSION).CANONICAL_PRICEFEED();
        var (isRecent, price, ) = CanonicalPriceFeed(feedAddress).getPriceInfo(MELON_ASSET);
        if (!isRecent) {
            revert();
        }
        return mul(price, amount) / 10 ** 18;
    }
    function calculatePayout(uint payin) view returns (uint payoutQuantity) {
        payoutQuantity = mul(payin, payoutRate) / 10 ** 18;
    }
    function getCompetitionStatusOfRegistrants()
        view
        returns(
            address[],
            address[],
            bool[]
        )
    {
        address[] memory fundAddrs = new address[](registrants.length);
        address[] memory fundRegistrants = new address[](registrants.length);
        bool[] memory isRewarded = new bool[](registrants.length);
        for (uint i = 0; i < registrants.length; i++) {
            fundAddrs[i] = registrants[i].fund;
            fundRegistrants[i] = registrants[i].registrant;
            isRewarded[i] = registrants[i].isRewarded;
        }
        return (fundAddrs, fundRegistrants, isRewarded);
    }
    function registerForCompetition(
        address fund,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        payable
        pre_cond(isCompetitionActive() && !Version(COMPETITION_VERSION).isShutDown())
        pre_cond(termsAndConditionsAreSigned(msg.sender, v, r, s) && isWhitelisted(msg.sender))
    {
        require(registeredFundToRegistrants[fund] == address(0) && registrantToRegistrantIds[msg.sender].exists == false);
        require(add(currentTotalBuyin, msg.value) <= totalMaxBuyin && registrants.length < maxRegistrants);
        require(msg.value <= whitelistantToMaxBuyin[msg.sender]);
        require(Version(COMPETITION_VERSION).getFundByManager(msg.sender) == fund);
        uint payoutQuantity = calculatePayout(msg.value);
        registeredFundToRegistrants[fund] = msg.sender;
        registrantToRegistrantIds[msg.sender] = RegistrantId({id: registrants.length, exists: true});
        currentTotalBuyin = add(currentTotalBuyin, msg.value);
        FundInterface fundContract = FundInterface(fund);
        MELON_CONTRACT.approve(fund, payoutQuantity);
        fundContract.requestInvestment(payoutQuantity, getEtherValue(payoutQuantity), MELON_ASSET);
        fundContract.executeRequest(fundContract.getLastRequestId());
        custodian.transfer(msg.value);
        emit Register(registrants.length, fund, msg.sender);
        registrants.push(Registrant({
            fund: fund,
            registrant: msg.sender,
            hasSigned: true,
            buyinQuantity: msg.value,
            payoutQuantity: payoutQuantity,
            isRewarded: false
        }));
    }
    function batchAddToWhitelist(
        uint maxBuyinQuantity,
        address[] whitelistants
    )
        pre_cond(isOwner())
        pre_cond(now < endTime)
    {
        for (uint i = 0; i < whitelistants.length; ++i) {
            whitelistantToMaxBuyin[whitelistants[i]] = maxBuyinQuantity;
        }
    }
    function withdrawMln(address to, uint amount)
        pre_cond(isOwner())
    {
        MELON_CONTRACT.transfer(to, amount);
    }
    function claimReward()
        pre_cond(getRegistrantFund(msg.sender) != address(0))
    {
        require(block.timestamp >= endTime || Version(COMPETITION_VERSION).isShutDown());
        Registrant registrant  = registrants[getRegistrantId(msg.sender)];
        require(registrant.isRewarded == false);
        registrant.isRewarded = true;
        uint balance = AssetInterface(registrant.fund).balanceOf(address(this));
        require(AssetInterface(registrant.fund).transfer(registrant.registrant, balance));
        emit ClaimReward(msg.sender, registrant.fund, balance);
    }
}
