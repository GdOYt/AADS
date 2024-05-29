contract ERC20Token is StandardToken {
    function () public {
        revert();
    }
    string public name;                    
    uint8 public decimals;                 
    string public symbol;                  
    string public version = 'H1.0';        
    function ERC20Token(
        ) public {
        balances[msg.sender] = 1000000000;                
        totalSupply = 1000000000;                         
        name = "2UP";                                    
        decimals = 2;                             
        symbol = "2UP";                                
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        if(!_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { revert(); }
        return true;
    }
}
