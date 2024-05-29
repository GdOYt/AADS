contract HumanStandardToken is StandardToken {
    function () {
        throw;
    }
    string public name;                    
    uint8 public decimals;                 
    string public symbol;                  
    string public version = 'H0.1';        
    uint256 public initialAmount = 360000000 * (10 ** 18);
    string tokenName = "Oneroot Network Token";
    uint8 decimalUnits =18;
    string tokenSymbol="RNT";
    function HumanStandardToken() {
        balances[msg.sender] = initialAmount;                
        totalSupply = initialAmount;                         
        name = tokenName;                                    
        decimals = decimalUnits;                             
        symbol = tokenSymbol;                                
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}
