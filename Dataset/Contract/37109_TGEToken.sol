contract TGEToken is MintableToken {
    string public name;       
    uint8 public decimals = 18;                
    string public symbol;                 
    string public version = "H0.1";
    function TGEToken(
        string _tokenName,
        string _tokenSymbol
        ) {
        name = _tokenName;
        symbol = _tokenSymbol;
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        assert(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
    }
    function burn(uint256 _value) returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            totalSupply -= _value;
            Transfer(msg.sender, 0x0, _value);
            return true;
        } else {
            return false;
        }
    }
}
