contract Slot is usingOraclize, EmergencyWithdrawalModule, DSMath {
    uint constant INVESTORS_EDGE = 200; 
    uint constant HOUSE_EDGE = 50;
    uint constant CAPITAL_RISK = 250;
    uint constant MAX_SPINS = 16;
    uint minBet = 1 wei;
    struct SpinsContainer {
        address playerAddress;
        uint nSpins;
        uint amountWagered;
    }
    mapping (bytes32 => SpinsContainer) spins;
    uint[] public probabilities;
    uint[] public multipliers;
    uint public totalAmountWagered; 
    event LOG_newSpinsContainer(bytes32 myid, address playerAddress, uint amountWagered, uint nSpins);
    event LOG_SpinExecuted(bytes32 myid, address playerAddress, uint spinIndex, uint numberDrawn);
    event LOG_SpinsContainerInfo(bytes32 myid, address playerAddress, uint netPayout);
    LedgerProofVerifyI externalContract;
    function Slot(address _verifierAddr) {
        externalContract = LedgerProofVerifyI(_verifierAddr);
    }
    function oraclize_randomDS_setCommitment(bytes32 queryId, bytes32 commitment) internal {
        externalContract.external_oraclize_randomDS_setCommitment(queryId, commitment);
    }
    modifier oraclize_randomDS_proofVerify(bytes32 _queryId, string _result, bytes _proof) {
        assert(externalContract.external_oraclize_randomDS_proofVerify(_proof, _queryId, bytes(_result), oraclize_getNetworkName()));
        _;
    }
    modifier onlyOraclize {
        assert(msg.sender == oraclize_cbAddress());
        _;
    }
    modifier onlyIfSpinsExist(bytes32 myid) {
        assert(spins[myid].playerAddress != address(0x0));
        _;
    }
    function isValidSize(uint _amountWagered) 
        constant 
        returns(bool) {
        uint netPotentialPayout = (_amountWagered * (10000 - INVESTORS_EDGE) * multipliers[0])/ 10000; 
        uint maxAllowedPayout = (CAPITAL_RISK * getBankroll())/10000;
        return ((netPotentialPayout <= maxAllowedPayout) && (_amountWagered >= minBet));
    }
    modifier onlyIfEnoughFunds(bytes32 myid) {
        if (isValidSize(spins[myid].amountWagered)) {
             _;
        }
        else {
            safeSend(spins[myid].playerAddress, spins[myid].amountWagered);
            delete spins[myid];
            return;
        }
    }
	modifier onlyLessThanMaxSpins (uint _nSpins) {
        assert(_nSpins <= MAX_SPINS);
        _;
    }
    modifier onlyIfFair(uint[] _prob, uint[] _payouts) {
        if (_prob.length != _payouts.length) revert();
        uint sum = 0;
        for (uint i = 0; i <_prob.length; i++) {
            sum += _prob[i] * _payouts[i];     
        }
        assert(sum == 10000);
        _;
    }
    function()
        payable {
        buySpins(1);
    }
    function buySpins(uint _nSpins) 
        payable 
        onlyLessThanMaxSpins(_nSpins) 
		onlyIfNotStopped {
        uint gas = _nSpins*ORACLIZE_PER_SPIN_GAS_LIMIT + ORACLIZE_BASE_GAS_LIMIT + safeGas;
        uint oraclizeFee = OraclizeI(OAR.getAddress()).getPrice("random", gas);
        if (oraclizeFee/multipliers[0] + oraclizeFee >= msg.value) revert();
        uint amountWagered = msg.value - oraclizeFee;
        uint maxNetPotentialPayout = (amountWagered * (10000 - INVESTORS_EDGE) * multipliers[0])/10000; 
        uint maxAllowedPayout = (CAPITAL_RISK * getBankroll())/10000;
        if ((maxNetPotentialPayout <= maxAllowedPayout) && (amountWagered >= minBet)) {
            bytes32 queryId = oraclize_newRandomDSQuery(0, 2*_nSpins, gas);
             spins[queryId] = 
                SpinsContainer(msg.sender,
                                    _nSpins,
                                    amountWagered
                                );
            LOG_newSpinsContainer(queryId, msg.sender, amountWagered, _nSpins);
            totalAmountWagered += amountWagered;
        } else {
            revert();
        }
    }
    function executeSpins(bytes32 myid, bytes randomBytes) 
        private 
        returns(uint)
    {
        uint amountWon = 0;
        uint numberDrawn = 0;
        uint rangeUpperEnd = 0;
        uint nSpins = spins[myid].nSpins;
        for (uint i = 0; i < 2*nSpins; i += 2) {
            numberDrawn = ((uint(randomBytes[i])*256 + uint(randomBytes[i+1]))*10000)/2**16;
            rangeUpperEnd = 0;
            LOG_SpinExecuted(myid, spins[myid].playerAddress, i/2, numberDrawn);
            for (uint j = 0; j < probabilities.length; j++) {
                rangeUpperEnd += probabilities[j];
                if (numberDrawn < rangeUpperEnd) {
                    amountWon += (spins[myid].amountWagered * multipliers[j]) / nSpins;
                    break;
                }
            }
        }
        return amountWon;
    }
    function sendPayout(bytes32 myid, uint payout) private {
        if (payout >= spins[myid].amountWagered) {
            investorsLosses += sub(payout, spins[myid].amountWagered);
            payout = (payout*(10000 - INVESTORS_EDGE))/10000;
        }
        else {
            uint tempProfit = add(investorsProfit, sub(spins[myid].amountWagered, payout));
            investorsProfit += (sub(spins[myid].amountWagered, payout)*(10000 - HOUSE_EDGE))/10000;
            safeSend(houseAddress, sub(tempProfit, investorsProfit));
        }
        LOG_SpinsContainerInfo(myid, spins[myid].playerAddress, payout);
        safeSend(spins[myid].playerAddress, payout);
    }
     function __callback(bytes32 myid, string result, bytes _proof) 
        onlyOraclize
        onlyIfSpinsExist(myid)
        onlyIfEnoughFunds(myid)
        oraclize_randomDS_proofVerify(myid, result, _proof)
    {
        uint payout = executeSpins(myid, bytes(result));
        sendPayout(myid, payout);
        delete profitDistributed;
        delete spins[myid];
    }
    function setConfiguration(uint[] _probabilities, uint[] _multipliers) 
        onlyOwner 
        onlyIfFair(_probabilities, _multipliers) {
        oraclize_setProof(proofType_Ledger);  
        delete probabilities;
        delete multipliers;
        uint lastProbability = 0;
        uint lastMultiplier = 2**256 - 1;
        for (uint i = 0; i < _probabilities.length; i++) {
            probabilities.push(_probabilities[i]);
            if (lastProbability >= _probabilities[i]) revert();
            lastProbability = _probabilities[i];
        }
        for (i = 0; i < _multipliers.length; i++) {
            multipliers.push(_multipliers[i]);
            if (lastMultiplier <= _multipliers[i]) revert();
            lastMultiplier = _multipliers[i];
        }
    }
    function setMinBet(uint _minBet) onlyOwner {
        minBet = _minBet;
    }
    function getSpinsContainer(bytes32 myid)
        constant
        returns(address, uint) {
        return (spins[myid].playerAddress, spins[myid].amountWagered); 
    }
    function getMinAmountToWager(uint _nSpins)
        onlyLessThanMaxSpins(_nSpins)
        constant
		returns(uint) {
        uint gas = _nSpins*ORACLIZE_PER_SPIN_GAS_LIMIT + ORACLIZE_BASE_GAS_LIMIT + safeGas;
        uint oraclizeFee = OraclizeI(OAR.getAddress()).getPrice("random", gas);
        return minBet + oraclizeFee/multipliers[0] + oraclizeFee;
    }
    function getMaxAmountToWager(uint _nSpins)
        onlyLessThanMaxSpins(_nSpins)
        constant
        returns(uint) {
        uint oraclizeFee = OraclizeI(OAR.getAddress()).getPrice("random", _nSpins*ORACLIZE_PER_SPIN_GAS_LIMIT + ORACLIZE_BASE_GAS_LIMIT + safeGas);
        uint maxWage =  (CAPITAL_RISK * getBankroll())*10000/((10000 - INVESTORS_EDGE)*10000*multipliers[0]);
        return maxWage + oraclizeFee;
    }
}
