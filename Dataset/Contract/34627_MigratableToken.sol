contract MigratableToken is Token {
    function MigratableToken() payable Token() {}
    bool stateMigrated = false;
    address public migrationAgent;
    uint public totalMigrated;
    address public migrationHost;
    mapping(address => bool) migratedInvestors;
    event Migrated(address indexed from, address indexed to, uint value);
    function setMigrationHost(address _address) external onlyOwner {
        require(_address != 0);
        migrationHost = _address;
    }
    function migrateStateFromHost() external onlyOwner {
        require(stateMigrated == false && migrationHost != 0);
        PreArtexToken preArtex = PreArtexToken(migrationHost);
        state = Stateful.State.PreSale;
        etherPriceUSDWEI = preArtex.etherPriceUSDWEI();
        beneficiary = preArtex.beneficiary();
        totalLimitUSDWEI = preArtex.totalLimitUSDWEI();
        minimalSuccessUSDWEI = preArtex.minimalSuccessUSDWEI();
        collectedUSDWEI = preArtex.collectedUSDWEI();
        crowdsaleStartTime = preArtex.crowdsaleStartTime();
        crowdsaleFinishTime = preArtex.crowdsaleFinishTime();
        stateMigrated = true;
    }
    function migrateInvestorsFromHost(uint batchSize) external onlyOwner {
        require(migrationHost != 0);
        PreArtexToken preArtex = PreArtexToken(migrationHost);
        uint numberOfInvestorsToMigrate = preArtex.numberOfInvestors();
        uint currentNumberOfInvestors = numberOfInvestors;
        require(currentNumberOfInvestors < numberOfInvestorsToMigrate);
        for (uint i = 0; i < batchSize; i++) {
            uint index = currentNumberOfInvestors + i;
            if (index < numberOfInvestorsToMigrate) {
                address investor = preArtex.investorsIter(index);
                migrateInvestorsFromHostInternal(investor, preArtex);                
            }
            else
                break;
        }
    }
    function migrateInvestorFromHost(address _address) external onlyOwner {
        require(migrationHost != 0);
        PreArtexToken preArtex = PreArtexToken(migrationHost);
        migrateInvestorsFromHostInternal(_address, preArtex);
    }
    function migrateInvestorsFromHostInternal(address _address, PreArtexToken preArtex) internal {
        require(state != State.SaleFailed && migratedInvestors[_address] == false);
        var (tokensToTransfer, weiToTransfer) = preArtex.investors(_address);
        require(tokensToTransfer > 0);
        balances[_address] = tokensToTransfer;
        totalSupply += tokensToTransfer;
        migratedInvestors[_address] = true;
        if (state != State.CrowdsaleCompleted) {
            Investor storage investor = investors[_address];
            investorsIter[numberOfInvestors] = _address;
            numberOfInvestors++;
            investor.amountTokens += tokensToTransfer;
            investor.amountWei += weiToTransfer;
        }
        Transfer(this, _address, tokensToTransfer);
    }
    function migrate() external {
        require(migrationAgent != 0);
        uint value = balances[msg.sender];
        balances[msg.sender] -= value;
        Transfer(msg.sender, this, value);
        totalSupply -= value;
        totalMigrated += value;
        MigrationAgent(migrationAgent).migrateFrom(msg.sender, value);
        Migrated(msg.sender, migrationAgent, value);
    }
    function setMigrationAgent(address _agent) external onlyOwner {
        require(migrationAgent == 0);
        migrationAgent = _agent;
    }
}
