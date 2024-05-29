contract JLSCoin is StandardToken {
    function () {
        throw;
    }
    string public name;                    
    uint8 public decimals;                 
    string public symbol;                  
    string public version = 'J1.0';        
    function JLSCoin(
        ) {
        balances[msg.sender] = 50000000*10**8;                
        totalSupply = 50000000*10**8;                         
        name = "Jules Coin";                                   
        decimals = 8;                             
        symbol = "JLS";                                
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}
