contract RENTCoin is DividendToken {
    string public constant name = "RentAway Coin";
    string public constant symbol = "RTW";
    uint32 public constant decimals = 18;
    function RENTCoin(uint256 initialSupply, uint unblockTime) public {
        totalSupply = initialSupply;
        balances[owner] = totalSupply;
        blockedUntil = unblockTime;
		Transfer(this, owner, totalSupply);
    }
    function manualTransfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) onlyOwner public returns (bool) {
        return transferSimple(_to, _value);
    }
}
