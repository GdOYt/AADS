contract HumanStandardToken is StandardToken {
    function () {
        throw;
    }
    string public name;                    
    uint8 public decimals;                 
    string public symbol;                  
    string public version = 'H0.1';        
    function HumanStandardToken(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol
        ) {
        balances[msg.sender] = _initialAmount;  
        totalSupply = _initialAmount;           
        name = _tokenName;                      
        decimals = _decimalUnits;               
        symbol = _tokenSymbol;                  
    }
}
