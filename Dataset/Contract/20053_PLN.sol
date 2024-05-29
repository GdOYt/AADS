contract PLN is StandardToken {
    function () {
        throw;
    }
    string public name = "Plutaneum";                    
    uint8 public decimals = 2;                 
    string public symbol = "PLN";                  
    string public version = 'H1.0';        
    function PLN(
        ) {
        balances[msg.sender] = 20000000000;                
        totalSupply = 20000000000;                         
        name = "Plutaneum";                                    
        decimals = 2;                             
        symbol = "PLN";                                
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}
