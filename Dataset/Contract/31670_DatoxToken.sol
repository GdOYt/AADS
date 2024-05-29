contract DatoxToken is StandardToken {
    function () {
        throw;
    }
    string public constant name = "DATOX";
    string public constant symbol = "DTX";
    uint8 public constant decimals = 8;
    uint256 public constant INITIAL_SUPPLY = 200000000 * (10 ** uint256(decimals));
    function DatoxToken() {
        balances[msg.sender] = INITIAL_SUPPLY;                
        totalSupply = INITIAL_SUPPLY;                         
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}
