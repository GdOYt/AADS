contract ERC20Token is HextracoinToken {
    function () {
        throw;
    }
    string public name;                    
    uint8 public decimals;                 
    string public symbol;                  
    string public version = 'H1.0';        
    function ERC20Token(
        ) {
        balances[msg.sender] = 290000000000;               
        totalSupply = 290000000000;                        
        name = "Hextracoin Token";                                  
        decimals = 4;                            
        symbol = "HXT";
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}
