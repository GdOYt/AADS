contract USTputOption is ExchangeUST {
    uint public initBlockEpoch = 40;
    uint public eachUserWeight = 10;
    uint public initEachPUST = 5*10**17 wei;
    uint public lastEpochBlock = block.number + initBlockEpoch;
    uint public price1=4*9995*10**17/10000;
    uint public price2=99993 * 10**17/100000;
    uint public eachPUSTprice = initEachPUST;
    uint public lastEpochTX = 0;
    uint public epochLast = 0;
    address public lastCallAddress;
    uint public lastCallPUST;
    event buyPUST (address caller, uint PUST);
    function () payable public {
        require (now < ExerciseEndTime);
        require (topTotalSupply > totalSupply);
        bool firstCallReward = false;
        uint epochNow = whichEpoch(block.number);
        if(epochNow != epochLast) {
            lastEpochBlock = safeAdd(lastEpochBlock, ((block.number - lastEpochBlock)/initBlockEpoch + 1)* initBlockEpoch);
            doReward();
            eachPUSTprice = calcpustprice(epochNow, epochLast);
            epochLast = epochNow;
            firstCallReward = true;
            lastEpochTX = 0;
        }
        uint _value = msg.value;
        uint _PUST = _value / eachPUSTprice;
        require(_PUST > 0);
        if (safeAdd(totalSupply, _PUST) > topTotalSupply) {
            _PUST = safeSub(topTotalSupply, totalSupply);
        }
        uint _refound = _value - _PUST * eachPUSTprice;
        if(_refound > 0) {
            msg.sender.transfer(_refound);
        }
        balances[msg.sender] = safeAdd(balances[msg.sender], _PUST);
        totalSupply = safeAdd(totalSupply, _PUST);
        emit buyPUST(msg.sender, _PUST);
        if(lastCallAddress == address(0) && epochLast == 0) {
             firstCallReward = true;
        }
        if (firstCallReward) {
            uint _firstReward = 0;
            _firstReward = (_PUST - 1) * 2 / 10 + 1;
            if (safeAdd(totalSupply, _firstReward) > topTotalSupply) {
                _firstReward = safeSub(topTotalSupply,totalSupply);
            }
            balances[msg.sender] = safeAdd(balances[msg.sender], _firstReward);
            totalSupply = safeAdd(totalSupply, _firstReward);
        }
        lastEpochTX += 1;
        lastCallAddress = msg.sender;
        lastCallPUST = _PUST;
        lastEpochBlock = safeAdd(lastEpochBlock, eachUserWeight);
    }
    function whichEpoch(uint _blocknumber) internal view returns (uint _epochNow) {
        if (lastEpochBlock >= _blocknumber ) {
            _epochNow = epochLast;
        }
        else {
            _epochNow = epochLast + (_blocknumber - lastEpochBlock) / initBlockEpoch + 1;
        }
    }
    function calcpustprice(uint _epochNow, uint _epochLast) public returns (uint _eachPUSTprice) {
        require (_epochNow - _epochLast > 0);    
        uint dif = _epochNow - _epochLast;
        uint dif100 = dif/100;
        dif = dif - dif100*100;        
        for(uint i=0;i<dif100;i++)
            {
                price1 = price1-price1*5/100;
                price2 = price2-price2*7/1000;
            }
        price1 = price1 - price1*5*dif/10000;
        price2 = price2 - price2*7*dif/100000;
        _eachPUSTprice = price1+price2;    
    }
    function doReward() internal returns (bool) {
        if (lastEpochTX == 1) return false;
        uint _lastReward = 0;
        if(lastCallPUST != 0) {
            _lastReward = (lastCallPUST-1) * 2 / 10 + 1;
        }
        if (safeAdd(totalSupply, _lastReward) > topTotalSupply) {
            _lastReward = safeSub(topTotalSupply,totalSupply);
        }
        balances[lastCallAddress] = safeAdd(balances[lastCallAddress], _lastReward);
        totalSupply = safeAdd(totalSupply, _lastReward);
    }
    function DepositETH() payable public {
        require (msg.sender == officialAddress);
        topTotalSupply += msg.value / 10**18;
    }
    function WithdrawETH() payable public onlyOwner {
        require (now >= ExerciseEndTime);
        officialAddress.transfer(address(this).balance);
    } 
    function allocLastTxRewardByHand() public onlyOwner returns (bool success) {
        lastEpochBlock = safeAdd(block.number, initBlockEpoch);
        doReward();
        success = true;
    }
}
