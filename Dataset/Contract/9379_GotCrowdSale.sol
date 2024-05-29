contract GotCrowdSale is Pausable, CanReclaimToken, ICOEngineInterface, KYCBase {
    uint256 public constant START_TIME = 1529416800;
    uint256 public constant END_TIME = 1530655140;                        
    uint256 public constant TOKEN_PER_ETHER = 740;                        
    uint256 public constant MONTHLY_INTERNAL_VAULT_CAP = 2.85e7 * 1e18;
    uint256 public constant PGO_UNLOCKED_LIQUIDITY_CAP = 1.5e7 * 1e18;
    uint256 public constant PGO_INTERNAL_RESERVE_CAP = 3.5e7 * 1e18;
    uint256 public constant RESERVED_PRESALE_CAP = 1.5754888e7 * 1e18;
    uint256 public constant RESERVATION_CAP = 0.4297111e7 * 1e18;
    uint256 public constant TOTAL_ICO_CAP = 0.5745112e7 * 1e18;
    uint256 public start;                                              
    uint256 public end;                                                
    uint256 public cap;                                                
    uint256 public tokenPerEth;
    uint256 public availableTokens;                                    
    address[] public kycSigners;                                       
    bool public capReached;
    uint256 public weiRaised;
    uint256 public tokensSold;
    PGOMonthlyInternalVault public pgoMonthlyInternalVault;
    PGOMonthlyPresaleVault public pgoMonthlyPresaleVault;
    PGOVault public pgoVault;
    address public pgoInternalReserveWallet;
    address public pgoUnlockedLiquidityWallet;
    address public wallet;
    GotToken public token;
    bool public didOwnerEndCrowdsale;
    constructor(
        address _token,
        address _wallet,
        address _pgoInternalReserveWallet,
        address _pgoUnlockedLiquidityWallet,
        address _pgoMonthlyInternalVault,
        address _pgoMonthlyPresaleVault,
        address[] _kycSigners
    )
        public
        KYCBase(_kycSigners)
    {
        require(END_TIME >= START_TIME);
        require(TOTAL_ICO_CAP > 0);
        start = START_TIME;
        end = END_TIME;
        cap = TOTAL_ICO_CAP;
        wallet = _wallet;
        tokenPerEth = TOKEN_PER_ETHER; 
        availableTokens = TOTAL_ICO_CAP;
        kycSigners = _kycSigners;
        token = GotToken(_token);
        pgoMonthlyInternalVault = PGOMonthlyInternalVault(_pgoMonthlyInternalVault);
        pgoMonthlyPresaleVault = PGOMonthlyPresaleVault(_pgoMonthlyPresaleVault);
        pgoInternalReserveWallet = _pgoInternalReserveWallet;
        pgoUnlockedLiquidityWallet = _pgoUnlockedLiquidityWallet;
        wallet = _wallet;
        pgoVault = new PGOVault(pgoInternalReserveWallet, address(token), END_TIME);
    }
    function mintPreAllocatedTokens() public onlyOwner {
        mintTokens(pgoUnlockedLiquidityWallet, PGO_UNLOCKED_LIQUIDITY_CAP);
        mintTokens(address(pgoVault), PGO_INTERNAL_RESERVE_CAP);
    }
    function initPGOMonthlyInternalVault(address[] beneficiaries, uint256[] balances)
        public
        onlyOwner
        equalLength(beneficiaries, balances)
    {
        uint256 totalInternalBalance = 0;
        uint256 balancesLength = balances.length;
        for (uint256 i = 0; i < balancesLength; i++) {
            totalInternalBalance = totalInternalBalance.add(balances[i]);
        }
        require(totalInternalBalance == MONTHLY_INTERNAL_VAULT_CAP);
        pgoMonthlyInternalVault.init(beneficiaries, balances, END_TIME, token);
        mintTokens(address(pgoMonthlyInternalVault), MONTHLY_INTERNAL_VAULT_CAP);
    }
    function initPGOMonthlyPresaleVault(address[] beneficiaries, uint256[] balances)
        public
        onlyOwner
        equalLength(beneficiaries, balances)
    {
        uint256 totalPresaleBalance = 0;
        uint256 balancesLength = balances.length;
        for (uint256 i = 0; i < balancesLength; i++) {
            totalPresaleBalance = totalPresaleBalance.add(balances[i]);
        }
        require(totalPresaleBalance == RESERVED_PRESALE_CAP);
        pgoMonthlyPresaleVault.init(beneficiaries, balances, END_TIME, token);
        mintTokens(address(pgoMonthlyPresaleVault), totalPresaleBalance);
    }
    function mintReservation(address[] beneficiaries, uint256[] balances)
        public
        onlyOwner
        equalLength(beneficiaries, balances)
    {
        uint256 totalReservationBalance = 0;
        uint256 balancesLength = balances.length;
        for (uint256 i = 0; i < balancesLength; i++) {
            totalReservationBalance = totalReservationBalance.add(balances[i]);
            uint256 amount = balances[i];
            tokensSold = tokensSold.add(amount);
            availableTokens = availableTokens.sub(amount);
            mintTokens(beneficiaries[i], amount);
        }
        require(totalReservationBalance <= RESERVATION_CAP);
    }
    function closeCrowdsale() public onlyOwner {
        require(block.timestamp >= START_TIME && block.timestamp < END_TIME);
        didOwnerEndCrowdsale = true;
    }
    function finalise() public onlyOwner {
        require(didOwnerEndCrowdsale || block.timestamp > end || capReached);
        token.finishMinting();
        token.unpause();
        token.transferOwnership(owner);
    }
    function price() public view returns (uint256 _price) {
        return tokenPerEth;
    }
    function started() public view returns(bool) {
        if (block.timestamp >= start) {
            return true;
        } else {
            return false;
        }
    }
    function ended() public view returns(bool) {
        if (block.timestamp >= end) {
            return true;
        } else {
            return false;
        }
    }
    function startTime() public view returns(uint) {
        return start;
    }
    function endTime() public view returns(uint) {
        return end;
    }
    function totalTokens() public view returns(uint) {
        return cap;
    }
    function remainingTokens() public view returns(uint) {
        return availableTokens;
    }
    function senderAllowedFor(address buyer) internal view returns(bool) {
        require(buyer != address(0));
        return true;
    }
    function releaseTokensTo(address buyer) internal returns(bool) {
        require(validPurchase());
        uint256 overflowTokens;
        uint256 refundWeiAmount;
        uint256 weiAmount = msg.value;
        uint256 tokenAmount = weiAmount.mul(price());
        if (tokenAmount >= availableTokens) {
            capReached = true;
            overflowTokens = tokenAmount.sub(availableTokens);
            tokenAmount = tokenAmount.sub(overflowTokens);
            refundWeiAmount = overflowTokens.div(price());
            weiAmount = weiAmount.sub(refundWeiAmount);
            buyer.transfer(refundWeiAmount);
        }
        weiRaised = weiRaised.add(weiAmount);
        tokensSold = tokensSold.add(tokenAmount);
        availableTokens = availableTokens.sub(tokenAmount);
        mintTokens(buyer, tokenAmount);
        forwardFunds(weiAmount);
        return true;
    }
    function forwardFunds(uint256 _weiAmount) internal {
        wallet.transfer(_weiAmount);
    }
    function validPurchase() internal view returns (bool) {
        require(!paused && !capReached);
        require(block.timestamp >= start && block.timestamp <= end);
        return true;
    }
    function mintTokens(address to, uint256 amount) private {
        token.mint(to, amount);
    }
    modifier equalLength(address[] beneficiaries, uint256[] balances) {
        require(beneficiaries.length == balances.length);
        _;
    }
}
