contract PreNTFToken is BurnableToken, Owned {
    string public constant name = "PreNTF Token";
    string public constant symbol = "PreNTF";
    uint32 public constant decimals = 18;
    function PreNTFToken(uint256 initialSupply, uint unblockTime) public {
        totalSupply = initialSupply;
        balances[owner] = initialSupply;
        blockedUntil = unblockTime;
    }
    function manualTransfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) onlyOwner public returns (bool) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }
}
