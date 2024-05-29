contract HumanStandardToken is StandardToken {
    string public name;                    
    uint8 public decimals;                 
    string public symbol;                  
    string public version = 'H0.1';        
    function HumanStandardToken(
        ) {
        balances[msg.sender] = 150000000000000000000000000;                
        totalSupply = 150000000000000000000000000;                         
        name = "BiBaoToken";                                    
        decimals = 18;                                         
        symbol = "BBT";                                
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
    }
}
