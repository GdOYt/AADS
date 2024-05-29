contract IPchainStandardToken is StandardToken {
    function () {
		return;
    }
    string public version = 'I0.1';        
    string public name;                    
    uint8 public decimals;                 
    string public symbol;                  
    function IPchainStandardToken(
        uint256 initialSupply,
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol
        ) {
        balances[msg.sender] = initialSupply;                
        totalSupply = initialSupply;                         
        name = tokenName;                                    
        decimals = decimalUnits;                             
        symbol = tokenSymbol;                                
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { 
        		return false;
        	 }
        return true;
    }
}
