contract BugXToken is StandardToken {
    string  public constant name = "BUGX2.0";
    string  public constant symbol = "BUGX";
    uint256 public constant decimals = 18;
    string  public version = "2.0";
    address public newContractAddr;          
    bool    public isFunding;                 
    uint256 public fundingStartBlock;
    uint256 public fundingStopBlock;
    uint256 public currentSupply;            
    uint256 public tokenRaised = 0;            
    uint256 public tokenIssued = 0;          
    uint256 public tokenMigrated = 0;      
    uint256 internal tokenExchangeRate = 9000;              
    uint256 internal tokenExchangeRateTwo = 9900;              
    uint256 internal tokenExchangeRateThree = 11250;              
    event AllocateToken(address indexed _to, uint256 _value);    
    event TakebackToken(address indexed _from, uint256 _value);    
    event RaiseToken(address indexed _to, uint256 _value);       
    event IssueToken(address indexed _to, uint256 _value);
    event IncreaseSupply(uint256 _value);
    event DecreaseSupply(uint256 _value);
    event Migrate(address indexed _addr, uint256 _tokens, uint256 _totaltokens);
    function formatDecimals(uint256 _value) internal pure returns (uint256 ) {
        return _value * 10 ** decimals;
    }
    constructor(
        address _ethFundDeposit,
        uint256 _currentSupply
        ) 
        public
    {
        require(_ethFundDeposit != address(0x0));
        ethFundDeposit = _ethFundDeposit;
        isFunding = false;                            
        fundingStartBlock = 0;
        fundingStopBlock = 0;
        currentSupply = formatDecimals(_currentSupply);
        totalSupply = formatDecimals(1500000000);     
        require(currentSupply <= totalSupply);
        balances[ethFundDeposit] = currentSupply;
        totalbalances[ethFundDeposit] = currentSupply;
    }
    function increaseSupply (uint256 _tokens) onlyOwner external {
        uint256 _value = formatDecimals(_tokens);
        require (_value + currentSupply <= totalSupply);
        currentSupply = safeAdd(currentSupply, _value);
        tokenadd(ethFundDeposit,_value);
        emit IncreaseSupply(_value);
    }
    function decreaseSupply (uint256 _tokens) onlyOwner external {
        uint256 _value = formatDecimals(_tokens);
        uint256 tokenCirculation = safeAdd(tokenRaised,tokenIssued);
        require (safeAdd(_value,tokenCirculation) <= currentSupply);
        currentSupply = safeSubtract(currentSupply, _value);
        tokensub(ethFundDeposit,_value);
        emit DecreaseSupply(_value);
    }
    modifier whenFunding() {
        require (isFunding);
        require (block.number >= fundingStartBlock);
        require (block.number <= fundingStopBlock);
        _;
    }
    function startFunding (uint256 _fundingStartBlock, uint256 _fundingStopBlock) onlyOwner external {
        require (!isFunding);
        require (_fundingStartBlock < _fundingStopBlock);
        require (block.number < _fundingStartBlock);
        fundingStartBlock = _fundingStartBlock;
        fundingStopBlock = _fundingStopBlock;
        isFunding = true;
    }
    function stopFunding() onlyOwner external {
        require (isFunding);
        isFunding = false;
    }
    function setMigrateContract(address _newContractAddr) onlyOwner external {
        require (_newContractAddr != newContractAddr);
        newContractAddr = _newContractAddr;
    }
    function migrate(address _addr) onlySelfOrOwner(_addr) external {
        require(!isFunding);
        require(newContractAddr != address(0x0));
        uint256 tokens_value = balances[_addr];
        uint256 totaltokens_value = totalbalances[_addr];
        require (tokens_value != 0 || totaltokens_value != 0);
        balances[_addr] = 0;
        totalbalances[_addr] = 0;
        IMigrationContract newContract = IMigrationContract(newContractAddr);
        require (newContract.migrate(_addr, tokens_value, totaltokens_value));
        tokenMigrated = safeAdd(tokenMigrated, totaltokens_value);
        emit Migrate(_addr, tokens_value, totaltokens_value);
    }
    function tokenRaise (address _addr,uint256 _value) internal {
        uint256 tokenCirculation = safeAdd(tokenRaised,tokenIssued);
        require (safeAdd(_value,tokenCirculation) <= currentSupply);
        tokenRaised = safeAdd(tokenRaised, _value);
        emit RaiseToken(_addr, _value);
    }
    function tokenIssue (address _addr,uint256 _value) internal {
        uint256 tokenCirculation = safeAdd(tokenRaised,tokenIssued);
        require (safeAdd(_value,tokenCirculation) <= currentSupply);
        tokenIssued = safeAdd(tokenIssued, _value);
        emit IssueToken(_addr, _value);
    }
    function tokenTakeback (address _addr,uint256 _value) internal {
        require (tokenIssued >= _value);
        tokenIssued = safeSubtract(tokenIssued, _value);
        emit TakebackToken(_addr, _value);
    }
    function tokenadd (address _addr,uint256 _value) internal {
        require(_value != 0);
        require (_addr != address(0x0));
        balances[_addr] = safeAdd(balances[_addr], _value);
        totalbalances[_addr] = safeAdd(totalbalances[_addr], _value);
    }
    function tokensub (address _addr,uint256 _value) internal {
        require(_value != 0);
        require (_addr != address(0x0));
        balances[_addr] = safeSubtract(balances[_addr], _value);
        totalbalances[_addr] = safeSubtract(totalbalances[_addr], _value);
    }
    function allocateToken(address _addr, uint256 _tokens) onlyOwner external {
        uint256 _value = formatDecimals(_tokens);
        tokenadd(_addr,_value);
        tokensub(ethFundDeposit,_value);
        tokenIssue(_addr,_value);
        emit Transfer(ethFundDeposit, _addr, _value);
    }
    function deductionToken (address _addr, uint256 _tokens) onlyOwner external {
        uint256 _value = formatDecimals(_tokens);
        tokensub(_addr,_value);
        tokenadd(ethFundDeposit,_value);
        tokenTakeback(_addr,_value);
        emit Transfer(_addr, ethFundDeposit, _value);
    }
    function addSegmentation(address _addr, uint256 _times,uint256 _period,uint256 _tokens) onlyOwner external returns (bool) {
        uint256 amount = userbalancesSegmentation[_addr][_times][_period];
        if (amount != 0 && _tokens != 0){
            uint256 _value = formatDecimals(_tokens);
            userbalancesSegmentation[_addr][_times][_period] = safeAdd(amount,_value);
            userbalances[_addr][_times] = safeAdd(userbalances[_addr][_times], _value);
            totalbalances[_addr] = safeAdd(totalbalances[_addr], _value);
            tokensub(ethFundDeposit,_value);
            tokenIssue(_addr,_value);
            return true;
        } else {
            return false;
        }
    }
    function subSegmentation(address _addr, uint256 _times,uint256 _period,uint256 _tokens) onlyOwner external returns (bool) {
        uint256 amount = userbalancesSegmentation[_addr][_times][_period];
        if (amount != 0 && _tokens != 0){
            uint256 _value = formatDecimals(_tokens);
            userbalancesSegmentation[_addr][_times][_period] = safeSubtract(amount,_value);
            userbalances[_addr][_times] = safeSubtract(userbalances[_addr][_times], _value);
            totalbalances[_addr] = safeSubtract(totalbalances[_addr], _value);
            tokenadd(ethFundDeposit,_value);
            tokenTakeback(_addr,_value);
            return true;
        } else {
            return false;
        }
    }
    function setTokenExchangeRate(uint256 _RateOne,uint256 _RateTwo,uint256 _RateThree) onlyOwner external {
        require (_RateOne != 0 && _RateTwo != 0 && _RateThree != 0);
        require (_RateOne != tokenExchangeRate && _RateTwo != tokenExchangeRateTwo && _RateThree != tokenExchangeRateThree);
        tokenExchangeRate = _RateOne;
        tokenExchangeRateTwo = _RateTwo;
        tokenExchangeRateThree = _RateThree;
    }
    function computeTokenAmount(uint256 _eth) internal view returns (uint256 tokens) {
        if(_eth > 0 && _eth < 100 ether){
            tokens = safeMult(_eth, tokenExchangeRate);
        }
        if (_eth >= 100 ether && _eth < 500 ether){
            tokens = safeMult(_eth, tokenExchangeRateTwo);
        }
        if (_eth >= 500 ether ){
            tokens = safeMult(_eth, tokenExchangeRateThree);
        }
    }
    function LockMechanismByOwner (
        address _addr,
        uint256 _tokens
    )
        external onlyOwner whenFunding
    {
        require (_tokens != 0);
        uint256 _value = formatDecimals(_tokens);
        tokenRaise(_addr,_value);
        tokensub(ethFundDeposit,_value);
        LockMechanism(_addr,_value);
        emit Transfer(ethFundDeposit,_addr,_value);
    }
    function transferETH() onlyOwner external {
        require (address(this).balance != 0);
        ethFundDeposit.transfer(address(this).balance);
    }
    function () public payable whenFunding {  
        require (msg.value != 0);
        uint256 _value = computeTokenAmount(msg.value);
        tokenRaise(msg.sender,_value);
        tokensub(ethFundDeposit,_value);
        LockMechanism(msg.sender,_value);
        emit Transfer(ethFundDeposit,msg.sender,_value);
    }
}
