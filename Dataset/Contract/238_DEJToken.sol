contract DEJToken is StandardToken, SafeMath {
    string  public constant name = "De Home";
    string  public constant symbol = "DEJ";
    uint256 public constant decimals = 18;
    string  public version = "1.0";
    address public ethFundDeposit;           
    address public newContractAddr;          
    bool    public isFunding;                 
    uint256 public fundingStartBlock;
    uint256 public fundingStopBlock;
    uint256 public currentSupply;            
    uint256 public tokenRaised = 0;          
    uint256 public tokenMigrated = 0;      
    event IncreaseSupply(uint256 _value);
    event DecreaseSupply(uint256 _value);
    function formatDecimals(uint256 _value) internal returns (uint256 ) {
        return _value * 10 ** decimals;
    }
    function DEJToken()
    {
        ethFundDeposit  = 0x697e6C6845212AE294E55E0adB13977de0F0BD37;
        isFunding = false;                            
        fundingStartBlock = 0;
        fundingStopBlock = 0;
        currentSupply = formatDecimals(1000000000);
        totalSupply = formatDecimals(1000000000);
        balances[msg.sender] = totalSupply;
        if(currentSupply > totalSupply) throw;
    }
    modifier isOwner()  { require(msg.sender == ethFundDeposit); _; }
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
    function transferETH() isOwner external {
        if (this.balance == 0) throw;
        if (!ethFundDeposit.send(this.balance)) throw;
    }
}
