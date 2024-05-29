contract Presale is PresaleOriginal {
    uint    public etherPrice;
    address public presaleOwner;
    enum State { Disabled, Presale, Finished }
    event NewState(State state);
    State   public state;
    uint    public presaleFinishTime;
    uint    public migrationCounter;
    function migrate(address _originalContract, uint n) public onlyOwner {
        require(state == State.Disabled);
        numberOfInvestors = PresaleOriginal(_originalContract).numberOfInvestors();
        uint limit = migrationCounter + n;
        if(limit > numberOfInvestors) {
            limit = numberOfInvestors;
        }
        for(; migrationCounter < limit; ++migrationCounter) {
            address a = PresaleOriginal(_originalContract).investorsIter(migrationCounter);
            investorsIter[migrationCounter] = a;
            uint256 amountTokens;
            uint amountWei;
            (amountTokens, amountWei) = PresaleOriginal(_originalContract).investors(a);
            amountTokens *= 2;
            investors[a].amountTokens = amountTokens;
            investors[a].amountWei = amountWei;
            totalSupply += amountTokens;
            Transfer(_originalContract, a, amountTokens);
        }
        if(limit < numberOfInvestors) {
            return;
        }
        presaleStartTime = PresaleOriginal(_originalContract).presaleStartTime();
        collectedUSD = PresaleOriginal(_originalContract).collectedUSD();
        totalLimitUSD = PresaleOriginal(_originalContract).totalLimitUSD();
        address bountyAddress = 0x59B95A5e0268Cc843e6308FEf723544BaA6676c6;
        if(investors[bountyAddress].amountWei == 0 && investors[bountyAddress].amountTokens == 0) {
            investorsIter[numberOfInvestors++] = bountyAddress;
        }
        uint bountyTokens = 5 * PresaleOriginal(_originalContract).totalSupply() / 100;
        investors[bountyAddress].amountTokens += bountyTokens;
        totalSupply += bountyTokens;
    }
    function () payable public {
        require(state == State.Presale);
        require(now < presaleFinishTime);
        uint valueWei = msg.value;
        uint valueUSD = valueWei * etherPrice / 1000000000000000000;
        if (collectedUSD + valueUSD > totalLimitUSD) {  
            valueUSD = totalLimitUSD - collectedUSD;
            valueWei = valueUSD * 1000000000000000000 / etherPrice;
            require(msg.sender.call.gas(3000000).value(msg.value - valueWei)());
            collectedUSD = totalLimitUSD;  
        } else {
            collectedUSD += valueUSD;
        }
        uint256 tokensPer10USD = 130;
        if (valueUSD >= 100000) {
            tokensPer10USD = 150;
        }
        uint256 tokens = tokensPer10USD * valueUSD / 10;
        require(tokens > 0);
        Investor storage inv = investors[msg.sender];
        if (inv.amountWei == 0) {  
            investorsIter[numberOfInvestors++] = msg.sender;
        }
        require(inv.amountTokens + tokens > inv.amountTokens);  
        inv.amountTokens += tokens;
        inv.amountWei += valueWei;
        totalSupply += tokens;
        Transfer(this, msg.sender, tokens);
    }
    function startPresale(address _presaleOwner, uint _etherPrice) public onlyOwner {
        require(state == State.Disabled);
        presaleOwner = _presaleOwner;
        etherPrice = _etherPrice;
        presaleFinishTime = 1526342400;  
        state = State.Presale;
        totalLimitUSD = 500000;
        NewState(state);
    }
    function setEtherPrice(uint _etherPrice) public onlyOwner {
        require(state == State.Presale);
        etherPrice = _etherPrice;
    }
    function timeToFinishPresale() public constant returns(uint t) {
        require(state == State.Presale);
        if (now > presaleFinishTime) {
            t = 0;
        } else {
            t = presaleFinishTime - now;
        }
    }
    function finishPresale() public onlyOwner {
        require(state == State.Presale);
        require(now >= presaleFinishTime || collectedUSD == totalLimitUSD);
        require(presaleOwner.call.gas(3000000).value(this.balance)());
        state = State.Finished;
        NewState(state);
    }
    function withdraw() public onlyOwner {
        require(presaleOwner.call.gas(3000000).value(this.balance)());
    }
}
