contract ApolloCoinTokenSale is Ownable, CappedCrowdsale, WhitelistedCrowdsale {
    uint private constant HARD_CAP = 3000 ether;
    uint public constant TOTAL_APC_SUPPLY = 21000000;
    uint private constant ICO_RATE = 900;
    uint private constant TIER1_RATE = 1080;
    uint private constant TIER2_RATE = 1440;
    uint private constant TIER3_RATE = 1620;
    uint private constant TIER4_RATE = 1800; 
    address public constant TEAM_WALLET = 0xd55de4cdade91f8b3d0ad44e5bc0074840bcf287;
    uint public constant TEAM_AMOUNT = 4200000e18;
    address public constant EARLY_INVESTOR_WALLET = 0x67e84a30d6c33f90e9aef0b9147455f4c8d85208;
    uint public constant EARLY_INVESTOR_AMOUNT = 7350000e18;
    address private constant APOLLOCOIN_COMPANY_WALLET = 0x129c3e7ac8e80511d50a77d757bb040a1132f59c;
    uint public constant APOLLOCOIN_COMPANY_AMOUNT = 6300000e18;
    uint public constant NON_TRANSFERABLE_TIME = 10 days;    
    function ApolloCoinTokenSale(uint256 _icoStartTime, uint256 _presaleStartTime, uint256 _presaleEndTime) WhitelistedCrowdsale() CappedCrowdsale(HARD_CAP) StandardCrowdsale(_icoStartTime, _presaleStartTime, _presaleEndTime, ICO_RATE, TIER1_RATE, TIER2_RATE, TIER3_RATE, TIER4_RATE, APOLLOCOIN_COMPANY_WALLET) {
        token.transfer(TEAM_WALLET, TEAM_AMOUNT);
        token.transfer(EARLY_INVESTOR_WALLET, EARLY_INVESTOR_AMOUNT);
        token.transfer(APOLLOCOIN_COMPANY_WALLET, APOLLOCOIN_COMPANY_AMOUNT);
    }
    function createTokenContract () internal returns(StandardToken) {
        return new ApolloCoinToken(TOTAL_APC_SUPPLY, NON_TRANSFERABLE_TIME, APOLLOCOIN_COMPANY_WALLET, EARLY_INVESTOR_WALLET);
    }
    function drainRemainingToken () public onlyOwner {
        require(hasEnded());
        token.transfer(APOLLOCOIN_COMPANY_WALLET, token.balanceOf(this));
    }
}
