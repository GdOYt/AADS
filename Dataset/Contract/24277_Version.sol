contract Version is DBC, Owned, VersionInterface {
    bytes32 public constant TERMS_AND_CONDITIONS = 0xAA9C907B0D6B4890E7225C09CBC16A01CB97288840201AA7CDCB27F4ED7BF159;  
    address public COMPLIANCE = 0xFb5978C7ca78074B2044034CbdbC3f2E03Dfe2bA;  
    string public VERSION_NUMBER;  
    address public NATIVE_ASSET;  
    address public GOVERNANCE;  
    bool public IS_MAINNET;   
    bool public isShutDown;  
    address[] public listOfFunds;  
    mapping (address => address) public managerToFunds;  
    event FundUpdated(address ofFund);
    function Version(
        string versionNumber,
        address ofGovernance,
        address ofNativeAsset,
        bool isMainnet
    ) {
        VERSION_NUMBER = versionNumber;
        GOVERNANCE = ofGovernance;
        NATIVE_ASSET = ofNativeAsset;
        IS_MAINNET = isMainnet;
    }
    function shutDown() external pre_cond(msg.sender == GOVERNANCE) { isShutDown = true; }
    function setupFund(
        string ofFundName,
        address ofQuoteAsset,
        uint ofManagementFee,
        uint ofPerformanceFee,
        address ofCompliance,
        address ofRiskMgmt,
        address ofPriceFeed,
        address[] ofExchanges,
        address[] ofExchangeAdapters,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) {
        require(!isShutDown);
        require(termsAndConditionsAreSigned(v, r, s));
        require(managerToFunds[msg.sender] == 0);  
        address complianceModule;
        if (IS_MAINNET) {
            complianceModule = COMPLIANCE;   
        } else {
            complianceModule = ofCompliance;
        }
        address ofFund = new Fund(
            msg.sender,
            ofFundName,
            ofQuoteAsset,
            ofManagementFee,
            ofPerformanceFee,
            NATIVE_ASSET,
            ofCompliance,
            ofRiskMgmt,
            ofPriceFeed,
            ofExchanges,
            ofExchangeAdapters
        );
        listOfFunds.push(ofFund);
        managerToFunds[msg.sender] = ofFund;
        FundUpdated(ofFund);
    }
    function shutDownFund(address ofFund)
        pre_cond(isShutDown || managerToFunds[msg.sender] == ofFund)
    {
        Fund fund = Fund(ofFund);
        delete managerToFunds[msg.sender];
        fund.shutDown();
        FundUpdated(ofFund);
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
