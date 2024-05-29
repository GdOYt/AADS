contract oraclizeSettings is Owned {
	uint constant ORACLIZE_PER_SPIN_GAS_LIMIT = 6100;
	uint constant ORACLIZE_BASE_GAS_LIMIT = 200000;
	uint safeGas = 9000;
	event newGasLimit(uint _gasLimit);
	function setSafeGas(uint _gas) 
		onlyOwner 
	{
	    assert(ORACLIZE_BASE_GAS_LIMIT + safeGas >= ORACLIZE_BASE_GAS_LIMIT);
	    assert(safeGas <= 25000);
		safeGas = _gas;
		newGasLimit(_gas);
	}	
}
