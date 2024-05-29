contract InitialToken is StandardToken {
    string public name;                    
    uint8 public decimals;                 
    string public symbol;                  
    string public version = 'H0.1';        
     function InitialToken(
        ) public {
        uint256 indexPrice=210000000*1000000000000000000;
        balances[msg.sender] = indexPrice;                
        totalSupply = indexPrice;                         
        name = "best0";                                    
        decimals = 18;                             
        symbol = "bestOneTokenTest";      
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        require(_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
    }
}
