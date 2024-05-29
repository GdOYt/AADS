contract MXLToken is StandardToken {
    function () {
        throw;
    }
    string public name = 'MXL Token';                  
    uint8 public decimals = 18;                
    string public symbol = 'MXL';              
    string public version = 'H0.1';      
    function MXLToken() {
        balances[msg.sender] = 999999999000000000000000000;   
        totalSupply = 999999999000000000000000000;            
        name = 'MXL Token';                                   
        decimals = 18;                                        
        symbol = 'MXL';                                       
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}
