contract ICOTokenExtended is ICOToken {
    address public refunder;
    IHookOperator public hookOperator;
    ExchangeOracle public aiurExchangeOracle;
    mapping(address => bool) public minters;
    uint256 public constant MIN_REFUND_RATE_DELIMITER = 2;  
    event LogRefunderSet(address refunderAddress);
    event LogTransferOverFunds(address from, address to, uint ethersAmount, uint tokensAmount);
    event LogTaxTransfer(address from, address to, uint amount);
    event LogMinterAdd(address addedMinter);
    event LogMinterRemove(address removedMinter);
    modifier onlyMinter(){
        require(minters[msg.sender]);
        _;
    }
    modifier onlyCurrentHookOperator() {
        require(msg.sender == address(hookOperator));
        _;
    }
    modifier nonZeroAddress(address inputAddress) {
        require(inputAddress != address(0));
        _;
    }
    modifier onlyRefunder() {
        require(msg.sender == refunder);
        _;
    }
    constructor() public {
        minters[msg.sender] = true;
    }
    function setRefunder(address refunderAddress) external onlyOwner nonZeroAddress(refunderAddress) {
        refunder = refunderAddress;
        emit LogRefunderSet(refunderAddress);
    }
    function setExchangeOracle(address exchangeOracleAddress) external onlyOwner nonZeroAddress(exchangeOracleAddress) {
        aiurExchangeOracle = ExchangeOracle(exchangeOracleAddress);
    }
    function setHookOperator(address hookOperatorAddress) external onlyOwner nonZeroAddress(hookOperatorAddress) {
        hookOperator = IHookOperator(hookOperatorAddress);
    }
    function addMinter(address minterAddress) external onlyOwner nonZeroAddress(minterAddress) {
        minters[minterAddress] = true;    
        emit LogMinterAdd(minterAddress);
    }
    function removeMinter(address minterAddress) external onlyOwner nonZeroAddress(minterAddress) {
        minters[minterAddress] = false;    
        emit LogMinterRemove(minterAddress);
    }
    function mint(address to, uint256 tokensAmount) public onlyMinter canMint nonZeroAddress(to) returns(bool) {
        hookOperator.onMint(to, tokensAmount);
        totalSupply = totalSupply.add(tokensAmount);
        balances[to] = balances[to].add(tokensAmount);
        emit Mint(to, tokensAmount);
        emit Transfer(address(0), to, tokensAmount);
        return true;
    } 
    function burn(uint tokensAmount) public {
        hookOperator.onBurn(tokensAmount);       
        super.burn(tokensAmount);  
    } 
    function transfer(address to, uint tokensAmount) public nonZeroAddress(to) returns(bool) {
        hookOperator.onTransfer(msg.sender, to, tokensAmount);
        return super.transfer(to, tokensAmount);
    }
    function transferFrom(address from, address to, uint tokensAmount) public nonZeroAddress(from) nonZeroAddress(to) returns(bool) {
        hookOperator.onTransfer(from, to, tokensAmount);
        return super.transferFrom(from, to, tokensAmount);
    }
    function taxTransfer(address from, address to, uint tokensAmount) external onlyCurrentHookOperator nonZeroAddress(from) nonZeroAddress(to) returns(bool) {  
        require(balances[from] >= tokensAmount);
        transferDirectly(from, to, tokensAmount);
        hookOperator.onTaxTransfer(from, tokensAmount);
        emit LogTaxTransfer(from, to, tokensAmount);
        return true;
    }
    function transferOverBalanceFunds(address from, address to, uint rate) external payable onlyRefunder nonZeroAddress(from) nonZeroAddress(to) returns(bool) {
        require(!hookOperator.isOverBalanceLimitHolder(from));
        uint256 oracleRate = aiurExchangeOracle.rate();
        require(rate <= oracleRate.add(oracleRate.div(MIN_REFUND_RATE_DELIMITER)));
        uint256 fromBalance = balanceOf(from);
        uint256 maxTokensBalance = totalSupply.mul(hookOperator.getBalancePercentageLimit()).div(100);
        require(fromBalance > maxTokensBalance);
        uint256 tokensToTake = fromBalance.sub(maxTokensBalance);
        uint256 weiToRefund = aiurExchangeOracle.convertTokensAmountInWeiAtRate(tokensToTake, rate);
        require(hookOperator.isInBalanceLimit(to, tokensToTake));
        require(msg.value == weiToRefund);
        transferDirectly(from, to, tokensToTake);
        from.transfer(msg.value);
        emit LogTransferOverFunds(from, to, weiToRefund, tokensToTake);
        return true;
    }
    function transferDirectly(address from, address to, uint tokensAmount) private {
        balances[from] = balances[from].sub(tokensAmount);
        balances[to] = balances[to].add(tokensAmount);
    }
}
