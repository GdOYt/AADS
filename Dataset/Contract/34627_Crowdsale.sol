contract Crowdsale is Owned, Stateful {
    uint public etherPriceUSDWEI;
    address public beneficiary;
    uint public totalLimitUSDWEI;
    uint public minimalSuccessUSDWEI;
    uint public collectedUSDWEI;
    uint public crowdsaleStartTime;
    uint public crowdsaleFinishTime;
    uint public tokenPriceUSDWEI = 100000000000000000;
    struct Investor {
        uint amountTokens;
        uint amountWei;
    }
    struct BtcDeposit {
        uint amountBTCWEI;
        uint btcPriceUSDWEI;
        address investor;
    }
    mapping(bytes32 => BtcDeposit) public btcDeposits;
    mapping(address => Investor) public investors;
    mapping(uint => address) public investorsIter;
    uint public numberOfInvestors;
    mapping(uint => address) public investorsToWithdrawIter;
    uint public numberOfInvestorsToWithdraw;
    function Crowdsale() payable Owned() {}
    function emitTokens(address _investor, uint _usdwei) internal returns(uint tokensToEmit);
    function emitAdditionalTokens() internal;
    function burnTokens(address _address, uint _amount) internal;
    function() payable crowdsaleState limitNotExceeded crowdsaleNotFinished {
        uint valueWEI = msg.value;
        uint valueUSDWEI = valueWEI * etherPriceUSDWEI / 1 ether;
        if (collectedUSDWEI + valueUSDWEI > totalLimitUSDWEI) {  
            valueUSDWEI = totalLimitUSDWEI - collectedUSDWEI;
            valueWEI = valueUSDWEI * 1 ether / etherPriceUSDWEI;
            uint weiToReturn = msg.value - valueWEI;
            bool isSent = msg.sender.call.gas(3000000).value(weiToReturn)();
            require(isSent);
            collectedUSDWEI = totalLimitUSDWEI;  
        } else {
            collectedUSDWEI += valueUSDWEI;
        }
        emitTokensFor(msg.sender, valueUSDWEI, valueWEI);
    }
    function depositUSD(address _to, uint _amountUSDWEI) external onlyOwner crowdsaleState limitNotExceeded crowdsaleNotFinished {
        collectedUSDWEI += _amountUSDWEI;
        emitTokensFor(_to, _amountUSDWEI, 0);
    }
    function depositBTC(address _to, uint _amountBTCWEI, uint _btcPriceUSDWEI, bytes32 _btcTxId) external onlyOwnerOrBtcOracle crowdsaleState limitNotExceeded crowdsaleNotFinished {
        uint valueUSDWEI = _amountBTCWEI * _btcPriceUSDWEI / 1 ether;
        BtcDeposit storage btcDep = btcDeposits[_btcTxId];
        require(btcDep.amountBTCWEI == 0);
        btcDep.amountBTCWEI = _amountBTCWEI;
        btcDep.btcPriceUSDWEI = _btcPriceUSDWEI;
        btcDep.investor = _to;
        collectedUSDWEI += valueUSDWEI;
        emitTokensFor(_to, valueUSDWEI, 0);
    }
    function emitTokensFor(address _investor, uint _valueUSDWEI, uint _valueWEI) internal {
        var emittedTokens = emitTokens(_investor, _valueUSDWEI);
        Investor storage inv = investors[_investor];
        if (inv.amountTokens == 0) {  
            investorsIter[numberOfInvestors++] = _investor;
        }
        inv.amountTokens += emittedTokens;
        if (state == State.Sale) {
            inv.amountWei += _valueWEI;
        }
    }
    function startPreSale(
        address _beneficiary,
        uint _etherPriceUSDWEI,
        uint _totalLimitUSDWEI,
        uint _crowdsaleDurationDays) external onlyOwner {
        require(state == State.Initial);
        crowdsaleStartTime = now;
        beneficiary = _beneficiary;
        etherPriceUSDWEI = _etherPriceUSDWEI;
        totalLimitUSDWEI = _totalLimitUSDWEI;
        crowdsaleFinishTime = now + _crowdsaleDurationDays * 1 days;
        collectedUSDWEI = 0;
        setState(State.PreSale);
    }
    function finishPreSale() public onlyOwner {
        require(state == State.PreSale);
        bool isSent = beneficiary.call.gas(3000000).value(this.balance)();
        require(isSent);
        setState(State.WaitingForSale);
    }
    function startSale(
        address _beneficiary,
        uint _etherPriceUSDWEI,
        uint _totalLimitUSDWEI,
        uint _crowdsaleDurationDays,
        uint _minimalSuccessUSDWEI) external onlyOwner {
        require(state == State.WaitingForSale);
        crowdsaleStartTime = now;
        beneficiary = _beneficiary;
        etherPriceUSDWEI = _etherPriceUSDWEI;
        totalLimitUSDWEI = _totalLimitUSDWEI;
        crowdsaleFinishTime = now + _crowdsaleDurationDays * 1 days;
        minimalSuccessUSDWEI = _minimalSuccessUSDWEI;
        collectedUSDWEI = 0;
        setState(State.Sale);
    }
    function failSale(uint _investorsToProcess) public {
        require(state == State.Sale);
        require(now >= crowdsaleFinishTime && collectedUSDWEI < minimalSuccessUSDWEI);
        while (_investorsToProcess > 0 && numberOfInvestors > 0) {
            address addr = investorsIter[--numberOfInvestors];
            Investor memory inv = investors[addr];
            burnTokens(addr, inv.amountTokens);
            --_investorsToProcess;
            delete investorsIter[numberOfInvestors];
            investorsToWithdrawIter[numberOfInvestorsToWithdraw] = addr;
            numberOfInvestorsToWithdraw++;
        }
        if (numberOfInvestors > 0) {
            return;
        }
        setState(State.SaleFailed);
    }
    function completeSale(uint _investorsToProcess) public onlyOwner {
        require(state == State.Sale);
        require(collectedUSDWEI >= minimalSuccessUSDWEI);
        while (_investorsToProcess > 0 && numberOfInvestors > 0) {
            --numberOfInvestors;
            --_investorsToProcess;
            delete investors[investorsIter[numberOfInvestors]];
            delete investorsIter[numberOfInvestors];
        }
        if (numberOfInvestors > 0) {
            return;
        }
        emitAdditionalTokens();
        bool isSent = beneficiary.call.gas(3000000).value(this.balance)();
        require(isSent);
        setState(State.CrowdsaleCompleted);
    }
    function setEtherPriceUSDWEI(uint _etherPriceUSDWEI) external onlyOwnerOrOracle {
        etherPriceUSDWEI = _etherPriceUSDWEI;
    }
    function setBeneficiary(address _beneficiary) external onlyOwner() {
        require(_beneficiary != 0);
        beneficiary = _beneficiary;
    }
    function withdrawBack() external saleFailedState {
        returnInvestmentsToInternal(msg.sender);
    }
    function returnInvestments(uint _investorsToProcess) public saleFailedState {
        while (_investorsToProcess > 0 && numberOfInvestorsToWithdraw > 0) {
            address addr = investorsToWithdrawIter[--numberOfInvestorsToWithdraw];
            delete investorsToWithdrawIter[numberOfInvestorsToWithdraw];
            --_investorsToProcess;
            returnInvestmentsToInternal(addr);
        }
    }
    function returnInvestmentsTo(address _to) public saleFailedState {
        returnInvestmentsToInternal(_to);
    }
    function returnInvestmentsToInternal(address _to) internal {
        Investor memory inv = investors[_to];
        uint value = inv.amountWei;
        if (value > 0) {
            delete investors[_to];
            require(_to.call.gas(3000000).value(value)());
        }
    }
    function withdrawFunds(uint _value) public onlyOwner {
        require(state == State.PreSale || (state == State.Sale && collectedUSDWEI > minimalSuccessUSDWEI));
        if (_value == 0) {
            _value = this.balance;
        }
        bool isSent = beneficiary.call.gas(3000000).value(_value)();
        require(isSent);
    }
    modifier crowdsaleNotFinished {
        require(now < crowdsaleFinishTime);
        _;
    }
    modifier limitNotExceeded {
        require(collectedUSDWEI < totalLimitUSDWEI);
        _;
    }
    modifier crowdsaleState {
        require(state == State.PreSale || state == State.Sale);
        _;
    }
    modifier saleFailedState {
        require(state == State.SaleFailed);
        _;
    }
    modifier completedSaleState {
        require(state == State.CrowdsaleCompleted);
        _;
    }
}
