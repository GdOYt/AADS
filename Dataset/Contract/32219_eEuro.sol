contract eEuro is StandardToken {
    function () {
        throw;
    }
    string public name;                    
    uint8 public decimals;                 
    string public symbol;                  
    string public version = 'H1.0';        
    function eEuro(
        ) {
        balances[msg.sender] = 510000000000000000000000000;              
        totalSupply = 510000000000000000000000000;                       
        name = "eEuro";                                
        decimals = 18;                            
        symbol = "eEUR";                           
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}
