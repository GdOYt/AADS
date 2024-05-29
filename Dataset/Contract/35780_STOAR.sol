contract STOAR is StandardToken {
    function () {
        throw;
    }
    string public name;                    
    uint8 public decimals;                 
    string public symbol;               
    string public version = 'STOAR 1.0';        
    function STOAR(
        ) {
        balances[msg.sender] = 100000000;                
        totalSupply = 100000000;                         
        name = "STOAR";                                    
        decimals = 0;                             
        symbol = "STOAR";                                
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}
