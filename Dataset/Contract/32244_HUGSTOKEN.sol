contract HUGSTOKEN is StandardToken {
    function () {
        throw;
    }
    string public name = "Hugs Tokens";                    
    uint8 public decimals = 0;                 
    string public symbol = "HUG";                  
    string public version = 'H1.0';        
    function HUGSTOKEN(
        ) {
        balances[msg.sender] = 500000;                
        totalSupply = 500000;                         
        name = "HUGS TOKEN";                                    
        decimals = 0;                             
        symbol = "HUG";                                
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}
