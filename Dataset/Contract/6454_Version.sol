contract Version is DBC, Owned, VersionInterface {
    bytes32 public constant TERMS_AND_CONDITIONS = 0xAA9C907B0D6B4890E7225C09CBC16A01CB97288840201AA7CDCB27F4ED7BF159;  
    string public VERSION_NUMBER;  
    address public MELON_ASSET;  
    address public NATIVE_ASSET;  
    address public GOVERNANCE;  
    address public CANONICAL_PRICEFEED;  
    bool public isShutDown;  
    address public COMPLIANCE;  
    address[] public listOfFunds;  
    mapping (address => address) public managerToFunds;  
    event FundUpdated(address ofFund);
    function Version(
        string versionNumber,
        address ofGovernance,
        address ofMelonAsset,
        address ofNativeAsset,
        address ofCanonicalPriceFeed,
        address ofCompetitionCompliance
    ) {
        VERSION_NUMBER = versionNumber;
        GOVERNANCE = ofGovernance;
        MELON_ASSET = ofMelonAsset;
        NATIVE_ASSET = ofNativeAsset;
        CANONICAL_PRICEFEED = ofCanonicalPriceFeed;
        COMPLIANCE = ofCompetitionCompliance;
    }
    function shutDown() external pre_cond(msg.sender == GOVERNANCE) { isShutDown = true; }
    function setupFund(
        bytes32 ofFundName,
        address ofQuoteAsset,
        uint ofManagementFee,
        uint ofPerformanceFee,
        address ofCompliance,
        address ofRiskMgmt,
        address[] ofExchanges,
        address[] ofDefaultAssets,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) {
        require(!isShutDown);
        require(termsAndConditionsAreSigned(v, r, s));
        require(CompetitionCompliance(COMPLIANCE).isCompetitionAllowed(msg.sender));
        require(managerToFunds[msg.sender] == address(0));  
        address[] memory melonAsDefaultAsset = new address[](1);
        melonAsDefaultAsset[0] = MELON_ASSET;  
        address ofFund = new Fund(
            msg.sender,
            ofFundName,
            NATIVE_ASSET,
            0,
            0,
            COMPLIANCE,
            ofRiskMgmt,
            CANONICAL_PRICEFEED,
            ofExchanges,
            melonAsDefaultAsset
        );
        listOfFunds.push(ofFund);
        managerToFunds[msg.sender] = ofFund;
        emit FundUpdated(ofFund);
    }
    function shutDownFund(address ofFund)
        pre_cond(isShutDown || managerToFunds[msg.sender] == ofFund)
    {
        Fund fund = Fund(ofFund);
        delete managerToFunds[msg.sender];
        fund.shutDown();
        emit FundUpdated(ofFund);
    }
    function termsAndConditionsAreSigned(uint8 v, bytes32 r, bytes32 s) view returns (bool signed) {
        return ecrecover(
            keccak256("\x19Ethereum Signed Message:\n32", TERMS_AND_CONDITIONS),
            v,
            r,
            s
        ) == msg.sender;  
    }
    function getNativeAsset() view returns (address) { return NATIVE_ASSET; }
    function getFundById(uint withId) view returns (address) { return listOfFunds[withId]; }
    function getLastFundId() view returns (uint) { return listOfFunds.length - 1; }
    function getFundByManager(address ofManager) view returns (address) { return managerToFunds[ofManager]; }
}
