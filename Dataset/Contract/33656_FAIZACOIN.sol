contract FAIZACOIN is StandardToken {
    function () {
        throw;
    }
    string public name = 'FAIZACOIN';                    
    uint8 public decimals = 0;                 
    string public symbol = 'FZC';                  
    string public version = 'H1.0';        
    function FAIZACOIN(
        ) {
        balances[msg.sender] = 100000000;            
        totalSupply = 100000000;                         
        name = "FAIZA Coin";                             
        decimals = 0;                                  
        symbol = "FZC";                                
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}
