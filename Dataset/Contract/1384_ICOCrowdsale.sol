contract ICOCrowdsale is Ownable, FinalizableCrowdsale, WhitelistedCrowdsale {
    using SafeMath for uint256;
    IUserManager public userManagerContract;
    uint256 public preSalesEndDate;
    uint256 public totalMintedBountyTokens;
    bool public isPresalesNotEndedInAdvance = true;
    uint256 public constant MIN_CONTRIBUTION_AMOUNT = 50 finney;  
    uint256 public constant MAX_BOUNTYTOKENS_AMOUNT = 100000 * (10**18);  
    uint256 public constant MAX_FUNDS_RAISED_DURING_PRESALE = 20000 ether;
    uint256 public constant MAX_USER_TOKENS_BALANCE = 400000 * (10**18);  
    uint256 public constant REGULAR_RATE = 100;
    uint256 public constant PUBLIC_SALES_SPECIAL_USERS_RATE = 120;  
    uint256 public constant DEFAULT_PRESALES_DURATION = 7 weeks;
    uint256 public constant MAX_PRESALES_EXTENSION= 12 weeks;
    uint256 public constant PUBLIC_SALES_1_PERIOD_END = 1 weeks;
    uint256 public constant PUBLIC_SALES_2_PERIOD_END = 2 weeks;
    uint256 public constant PUBLIC_SALES_3_PERIOD_END = 3 weeks;
    uint256 public constant PUBLIC_SALES_1_RATE = 115;  
    uint256 public constant PUBLIC_SALES_2_RATE = 110;  
    uint256 public constant PUBLIC_SALES_3_RATE = 105;  
    event LogBountyTokenMinted(address minter, address beneficiary, uint256 amount);
    event LogPrivatesaleExtend(uint extensionTime);
    constructor(uint256 startTime, uint256 endTime, address wallet, address hookOperatorAddress) public
        FinalizableCrowdsale()
        Crowdsale(startTime, endTime, REGULAR_RATE, wallet)
    {
        preSalesEndDate = startTime.add(DEFAULT_PRESALES_DURATION);
        ICOTokenExtended icoToken = ICOTokenExtended(token);
        icoToken.setHookOperator(hookOperatorAddress);
    }
    function createTokenContract() internal returns (MintableToken) {
        ICOTokenExtended icoToken = new ICOTokenExtended();
        icoToken.pause();
        return icoToken;
    }
    function finalization() internal {
        super.finalization();
        ICOTokenExtended icoToken = ICOTokenExtended(token);
        icoToken.transferOwnership(owner);
    }
    function extendPreSalesPeriodWith(uint extensionTime) public onlyOwner {
        require(extensionTime <= MAX_PRESALES_EXTENSION);
        preSalesEndDate = preSalesEndDate.add(extensionTime);
        endTime = endTime.add(extensionTime);
        emit LogPrivatesaleExtend(extensionTime);
    }
    function buyTokens(address beneficiary) public payable {
        require(msg.value >= MIN_CONTRIBUTION_AMOUNT);
        require(beneficiary != address(0));
        require(validPurchase());
        uint256 weiAmount = msg.value;
        uint256 tokens = getTokenAmount(weiAmount, beneficiary);
        uint256 beneficiaryBalance = token.balanceOf(beneficiary);
        require(beneficiaryBalance.add(tokens) <= MAX_USER_TOKENS_BALANCE);
        weiRaised = weiRaised.add(weiAmount);
        if(weiRaised >= MAX_FUNDS_RAISED_DURING_PRESALE && isPresalesNotEndedInAdvance){
            preSalesEndDate = now;
            isPresalesNotEndedInAdvance = false;
        }
        token.mint(beneficiary, tokens);
        userManagerContract.markUserAsFounder(beneficiary);
        emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
        forwardFunds();
    }
    function getTokenAmount(uint256 weiAmount, address beneficiaryAddress) internal view returns(uint256 tokenAmount) {
        uint256 crowdsaleRate = getRate(beneficiaryAddress);
        return weiAmount.mul(crowdsaleRate);
    }
    function getRate(address beneficiary) internal view returns(uint256) {
        if(now <= preSalesEndDate && weiRaised < MAX_FUNDS_RAISED_DURING_PRESALE){
            if(preSalesSpecialUsers[beneficiary] > 0){
                return preSalesSpecialUsers[beneficiary];
            }
            return REGULAR_RATE;
        }
        if(publicSalesSpecialUsers[beneficiary]){
            return PUBLIC_SALES_SPECIAL_USERS_RATE;
        }
        if(now <= preSalesEndDate.add(PUBLIC_SALES_1_PERIOD_END)) {
            return PUBLIC_SALES_1_RATE;
        }
        if(now <= preSalesEndDate.add(PUBLIC_SALES_2_PERIOD_END)) {
            return PUBLIC_SALES_2_RATE;
        }
        if(now <= preSalesEndDate.add(PUBLIC_SALES_3_PERIOD_END)) {
            return PUBLIC_SALES_3_RATE;
        }
        return REGULAR_RATE;
    }
    function createBountyToken(address beneficiary, uint256 amount) public onlyOwner returns(bool) {
        require(!hasEnded());
        require(totalMintedBountyTokens.add(amount) <= MAX_BOUNTYTOKENS_AMOUNT);
        totalMintedBountyTokens = totalMintedBountyTokens.add(amount);
        token.mint(beneficiary, amount);
        emit LogBountyTokenMinted(msg.sender, beneficiary, amount);
        return true;
    }
    function setUserManagerContract(address userManagerInstance) public onlyOwner {
        require(userManagerInstance != address(0));
        userManagerContract = IUserManager(userManagerInstance);
    }
}
