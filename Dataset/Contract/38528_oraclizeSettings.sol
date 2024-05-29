contract oraclizeSettings is Owned {
    uint constant ORACLIZE_PER_SPIN_GAS_LIMIT = 6100;
    uint constant ORACLIZE_BASE_GAS_LIMIT = 220000;
    uint safeGas = 9000;
    event LOG_newGasLimit(uint _gasLimit);
    function setSafeGas(uint _gas) 
            onlyOwner 
    {
        assert(ORACLIZE_BASE_GAS_LIMIT + _gas >= ORACLIZE_BASE_GAS_LIMIT);
        assert(_gas <= 25000);
        assert(_gas >= 9000); 
        safeGas = _gas;
        LOG_newGasLimit(_gas);
    }       
}
