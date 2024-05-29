contract KuaiCoin is StandardToken {
    function () {
        throw;
    }
    string public name = 'Kuai Coin';                    
    uint8 public decimals;                 
    string public symbol = 'KKC';                  
    string public version = 'H1.0';        
    function KuaiCoin(
        ) {
        balances[msg.sender] = 15000000000;                
        totalSupply = 15000000000;                         
        name = "Kuai Coin";                                    
        decimals = 0;                             
        symbol = "KKC";                                
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}
