contract LolaCoin is StandardToken {
    string public name;                    
    uint8 public decimals;                 
    string public symbol;                  
    string public version = 'L0.1';        
    uint256 public constant TOTAL = 1000000000000000000000000000;
    function LolaCoin() {
        balances[msg.sender] = TOTAL;                
        totalSupply = TOTAL;                         
        name = "Lola Coin";                                    
        decimals = 18;                             
        symbol = "LLC";                                
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
    }
}
