contract UnityToken is StandardToken, SafeMath {
    string  public constant name = "Ping";
    string  public constant symbol = "PIN";
    uint256 public constant decimals = 3;
    string  public version = "1.0";
    address public ethFundDeposit;           
    address public newContractAddr;          
    bool    public isFunding;                 
    uint256 public fundingStartBlock;
    uint256 public fundingStopBlock;
    uint256 public currentSupply;            
    uint256 public tokenRaised = 0;          
    uint256 public tokenMigrated = 0;      
    uint256 public tokenExchangeRate = 3;              
    event AllocateToken(address indexed _to, uint256 _value);    
    event IssueToken(address indexed _to, uint256 _value);       
    event IncreaseSupply(uint256 _value);
    event DecreaseSupply(uint256 _value);
    event Migrate(address indexed _to, uint256 _value);
    function formatDecimals(uint256 _value) internal returns (uint256 ) {
        return _value * 10 ** decimals;
    }
    function UnityToken(
        address _ethFundDeposit,
        uint256 _currentSupply)
    {
        ethFundDeposit = _ethFundDeposit;
        isFunding = false;                            
        fundingStartBlock = 0;
        fundingStopBlock = 0;
        currentSupply = formatDecimals(_currentSupply);
        totalSupply = formatDecimals(10000000);
        balances[msg.sender] = totalSupply;
        if(currentSupply > totalSupply) throw;
    }
    modifier isOwner()  { require(msg.sender == ethFundDeposit); _; }
    function setTokenExchangeRate(uint256 _tokenExchangeRate) isOwner external {
        if (_tokenExchangeRate == 0) throw;
        if (_tokenExchangeRate == tokenExchangeRate) throw;
        tokenExchangeRate = _tokenExchangeRate;
    }
    function increaseSupply (uint256 _value) isOwner external {
        uint256 value = formatDecimals(_value);
        if (value + currentSupply > totalSupply) throw;
        currentSupply = safeAdd(currentSupply, value);
        IncreaseSupply(value);
    }
    function decreaseSupply (uint256 _value) isOwner external {
        uint256 value = formatDecimals(_value);
        if (value + tokenRaised > currentSupply) throw;
        currentSupply = safeSubtract(currentSupply, value);
        DecreaseSupply(value);
    }
    function startFunding (uint256 _fundingStartBlock, uint256 _fundingStopBlock) isOwner external {
        if (isFunding) throw;
        if (_fundingStartBlock >= _fundingStopBlock) throw;
        if (block.number >= _fundingStartBlock) throw;
        fundingStartBlock = _fundingStartBlock;
        fundingStopBlock = _fundingStopBlock;
        isFunding = true;
    }
    function stopFunding() isOwner external {
        if (!isFunding) throw;
        isFunding = false;
    }
    function setMigrateContract(address _newContractAddr) isOwner external {
        if (_newContractAddr == newContractAddr) throw;
        newContractAddr = _newContractAddr;
    }
    function changeOwner(address _newFundDeposit) isOwner() external {
        if (_newFundDeposit == address(0x0)) throw;
        ethFundDeposit = _newFundDeposit;
    }
    function migrate() external {
        if(isFunding) throw;
        if(newContractAddr == address(0x0)) throw;
        uint256 tokens = balances[msg.sender];
        if (tokens == 0) throw;
        balances[msg.sender] = 0;
        tokenMigrated = safeAdd(tokenMigrated, tokens);
        IMigrationContract newContract = IMigrationContract(newContractAddr);
        if (!newContract.migrate(msg.sender, tokens)) throw;
        Migrate(msg.sender, tokens);                
    }
    function transferETH() isOwner external {
        if (this.balance == 0) throw;
        if (!ethFundDeposit.send(this.balance)) throw;
    }
    function allocateToken (address _addr, uint256 _fin) isOwner public {
        if (_fin == 0) throw;
        if (_addr == address(0x0)) throw;
        uint256 tokens = safeMult(formatDecimals(_fin), tokenExchangeRate);
        if (tokens + tokenRaised > currentSupply) throw;
        tokenRaised = safeAdd(tokenRaised, tokens);
        balances[_addr] += tokens;
        AllocateToken(_addr, tokens);   
    }
    function () payable {
        if (!isFunding) throw;
        if (msg.value == 0) throw;
        if (block.number < fundingStartBlock) throw;
        if (block.number > fundingStopBlock) throw;
        uint256 tokens = safeMult(msg.value, tokenExchangeRate);
        if (tokens + tokenRaised > currentSupply) throw;
        tokenRaised = safeAdd(tokenRaised, tokens);
        balances[msg.sender] += tokens;
        IssueToken(msg.sender, tokens);   
    }
}