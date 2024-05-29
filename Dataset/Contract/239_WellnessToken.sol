contract WellnessToken is StandardToken {  
    string public name;                    
    uint8 public decimals;                 
    string public symbol;                  
    string public version = 'H1.0'; 
    uint256 public WellnessToken ;      
    uint256 public totalEthInWei;          
    address  fundsWallet;            
    function WellnessToken() {
        balances[msg.sender] = 7600000000000000000000000000;                
        totalSupply = 7600000000000000000000000000;                         
        name = "WellnessToken";                                    
        decimals = 18;                                                
        symbol = "WELL";                                              
        fundsWallet = msg.sender;                                     
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}
