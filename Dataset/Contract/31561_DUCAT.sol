contract DUCAT is StandardToken {
    function() {
        throw;
    }
    string public name;
    uint8 public decimals;
    string public symbol;
    string public version = '2.0.0.RELEASE';
    function DUCAT() {
        balances[msg.sender] = 1000000000000000000000000000;
        totalSupply = 1000000000000000000000000000;
        name = "Ducat";
        decimals = 18;
        symbol = "DUCAT";
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        if (!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) {throw;}
        return true;
    }
}
