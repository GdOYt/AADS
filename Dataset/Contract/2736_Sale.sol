contract Sale is SaleI, Ownable, Whitelistable, TimedStateMachine, TokenControllerI {
    using SafeMath for uint256;
    using SafeERC20 for Token;
    bytes32 private constant SETUP = "setup";
    bytes32 private constant FREEZE = "freeze";
    bytes32 private constant SALE_IN_PROGRESS = "saleInProgress";
    bytes32 private constant SALE_ENDED = "saleEnded";
    bytes32[] public states = [SETUP, FREEZE, SALE_IN_PROGRESS, SALE_ENDED];
    mapping(address => uint256) public unitContributions;
    mapping(address => bool) public extraTokensAllocated;
    DisbursementHandler public disbursementHandler;
    uint256 public totalContributedUnits = 0;  
    uint256 public totalSaleCapUnits;  
    uint256 public minContributionUnits;  
    uint256 public minThresholdUnits;  
    uint256 public saleTokensPerUnit;
    uint256 public extraTokensPerUnit;
    uint256 public tokensForSale;
    Token public trustedToken;
    Vault public trustedVault;
    EthPriceFeedI public ethPriceFeed; 
    event Contribution(
        address indexed contributor,
        address indexed sender,
        uint256 valueUnit,
        uint256 valueWei,
        uint256 excessWei,
        uint256 weiPerUnitRate
    );
    event EthPriceFeedChanged(address previousEthPriceFeed, address newEthPriceFeed);
    event TokensAllocated(address indexed contributor, uint256 tokenAmount);
    constructor (
        uint256 _totalSaleCapUnits,  
        uint256 _minContributionUnits,  
        uint256 _minThresholdUnits,  
        uint256 _maxTokens,
        address _whitelistAdmin,
        address _wallet,
        uint256 _vaultInitialDisburseWei,  
        uint256 _vaultDisbursementWei,  
        uint256 _vaultDisbursementDuration,
        uint256 _startTime,
        string _tokenName,
        string _tokenSymbol,
        uint8 _tokenDecimals, 
        EthPriceFeedI _ethPriceFeed
    ) 
        Whitelistable(_whitelistAdmin)
        public 
    {
        require(_totalSaleCapUnits != 0);
        require(_maxTokens != 0);
        require(_wallet != 0);
        require(_minThresholdUnits <= _totalSaleCapUnits);
        require(_ethPriceFeed != address(0));
        require(now < _startTime);
        totalSaleCapUnits = _totalSaleCapUnits;
        minContributionUnits = _minContributionUnits;
        minThresholdUnits = _minThresholdUnits;
        trustedToken = new Token(
            _maxTokens,
            _tokenName,
            _tokenSymbol,
            _tokenDecimals
        );
        disbursementHandler = new DisbursementHandler(trustedToken);
        ethPriceFeed = _ethPriceFeed; 
        trustedToken.setController(this);
        trustedVault = new Vault(
            _wallet,
            _vaultInitialDisburseWei,
            _vaultDisbursementWei,  
            _vaultDisbursementDuration
        );
        setStates(states);
        allowFunction(SETUP, this.setup.selector);
        allowFunction(FREEZE, this.setEndTime.selector);
        allowFunction(SALE_IN_PROGRESS, this.setEndTime.selector);
        allowFunction(SALE_IN_PROGRESS, this.contribute.selector);
        allowFunction(SALE_IN_PROGRESS, this.endSale.selector);
        allowFunction(SALE_ENDED, this.allocateExtraTokens.selector);
        addStartCondition(SALE_ENDED, wasCapReached);
        setStateStartTime(SALE_IN_PROGRESS, _startTime);
        addCallback(SALE_ENDED, onSaleEnded);
    }
    function setup() external onlyOwner checkAllowed {
        trustedToken.safeTransfer(disbursementHandler, disbursementHandler.totalAmount());
        tokensForSale = trustedToken.balanceOf(this);     
        require(tokensForSale >= totalSaleCapUnits);
        saleTokensPerUnit = tokensForSale.div(totalSaleCapUnits);
        goToNextState();
    }
    function changeEthPriceFeed(EthPriceFeedI _ethPriceFeed) external onlyOwner {
        require(_ethPriceFeed != address(0));
        emit EthPriceFeedChanged(ethPriceFeed, _ethPriceFeed);
        ethPriceFeed = _ethPriceFeed;
    }
    function contribute(
        address _contributor,
        uint256 _contributionLimitUnits, 
        uint256 _payloadExpiration,
        bytes _sig
    ) 
        external 
        payable
        checkAllowed 
        isWhitelisted(keccak256(
            abi.encodePacked(
                _contributor,
                _contributionLimitUnits, 
                _payloadExpiration
            )
        ), _sig)
    {
        require(msg.sender == _contributor);
        require(now < _payloadExpiration); 
        uint256 weiPerUnitRate = ethPriceFeed.getRate(); 
        require(weiPerUnitRate != 0);
        uint256 previouslyContributedUnits = unitContributions[_contributor];
        uint256 currentContributionUnits = min256(
            _contributionLimitUnits.sub(previouslyContributedUnits),
            totalSaleCapUnits.sub(totalContributedUnits),
            msg.value.div(weiPerUnitRate)
        );
        require(currentContributionUnits != 0);
        require(currentContributionUnits >= minContributionUnits || previouslyContributedUnits != 0);
        unitContributions[_contributor] = previouslyContributedUnits.add(currentContributionUnits);
        totalContributedUnits = totalContributedUnits.add(currentContributionUnits);
        uint256 currentContributionWei = currentContributionUnits.mul(weiPerUnitRate);
        trustedVault.deposit.value(currentContributionWei)(msg.sender);
        if (totalContributedUnits >= minThresholdUnits &&
            trustedVault.state() != Vault.State.Success) {
            trustedVault.saleSuccessful();
        }
        uint256 excessWei = msg.value.sub(currentContributionWei);
        if (excessWei > 0) {
            msg.sender.transfer(excessWei);
        }
        emit Contribution(
            _contributor, 
            msg.sender,
            currentContributionUnits, 
            currentContributionWei, 
            excessWei,
            weiPerUnitRate
        );
        uint256 tokenAmount = currentContributionUnits.mul(saleTokensPerUnit);
        trustedToken.safeTransfer(_contributor, tokenAmount);
        emit TokensAllocated(_contributor, tokenAmount);
    }
    function allocateExtraTokens(address _contributor)
        external 
        checkAllowed
    {    
        require(!extraTokensAllocated[_contributor]);
        require(unitContributions[_contributor] != 0);
        require(totalContributedUnits < totalSaleCapUnits);
        extraTokensAllocated[_contributor] = true;
        uint256 tokenAmount = unitContributions[_contributor].mul(extraTokensPerUnit);
        trustedToken.safeTransfer(_contributor, tokenAmount);
        emit TokensAllocated(_contributor, tokenAmount);
    }
    function setEndTime(uint256 _endTime) external onlyOwner checkAllowed {
        require(now < _endTime);
        require(getStateStartTime(SALE_ENDED) == 0);
        setStateStartTime(SALE_ENDED, _endTime);
    }
    function enableRefunds() external onlyOwner {
        trustedVault.enableRefunds();
    }
    function endSale() external onlyOwner checkAllowed {
        goToNextState();
    }
    function transferAllowed(address _from, address)
        external
        view
        returns (bool)
    {
        return _from == address(this) || _from == address(disbursementHandler);
    }
    function setupDisbursement(
        address _beneficiary,
        uint256 _tokenAmount,
        uint256 _duration
    )
        internal 
    {
        require(tokensForSale == 0);
        disbursementHandler.setupDisbursement(
            _beneficiary,
            _tokenAmount,
            now.add(_duration)
        );
    }
    function wasCapReached(bytes32) internal returns (bool) {
        return totalSaleCapUnits <= totalContributedUnits;
    }
    function onSaleEnded() internal {
        trustedToken.transferOwnership(owner); 
        if (totalContributedUnits == 0) {
            trustedToken.safeTransfer(trustedVault.trustedWallet(), tokensForSale);
        } else if (totalContributedUnits < minThresholdUnits) {
            trustedVault.enableRefunds();
        } else {
            extraTokensPerUnit = tokensForSale.div(totalContributedUnits).sub(saleTokensPerUnit);
            trustedVault.close();
            trustedVault.transferOwnership(owner);
        }
    }
    function min256(uint256 x, uint256 y, uint256 z) internal pure returns (uint256) {
        return Math.min256(x, Math.min256(y, z));
    }
}
