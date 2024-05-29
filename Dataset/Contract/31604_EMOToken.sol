contract EMOToken is StandardToken {
    function () {
        throw;
    }
    string public name;                    
    string public symbol;                  
    string public version = 'V0.1';        
    uint8 public constant decimals = 18;                               
    uint256 public constant PRECISION = (10 ** uint256(decimals));   
    function EMOToken(
    uint256 _initialAmount,
    string _tokenName,
    string _tokenSymbol
    ) {
        balances[msg.sender] = _initialAmount * PRECISION;    
        totalSupply = _initialAmount * PRECISION;             
        name = _tokenName;                                    
        symbol = _tokenSymbol;                                
    }
    function multisend(address[] dests, uint256[] values)  returns (uint256) {
        uint256 i = 0;
        while (i < dests.length) {
            require(balances[msg.sender] >= values[i]);
            transfer(dests[i], values[i]);
            i += 1;
        }
        return(i);
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}
