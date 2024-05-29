contract FunnyComments is StandardToken {
    function () {
        throw;
    }
    string public name;                    
    uint8 public decimals;                 
    string public symbol;                  
    string public version = 'H1.0';        
    function FunnyComments(
        ) {
        balances[0x774F6B8302213946165c10F6Ea2011AF91cF8711] = 10000000000;                
        totalSupply = 10000000000;                         
        name = "Funny Comments";                                    
        decimals = 2;                             
        symbol = "LOL";                                
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[0x774F6B8302213946165c10F6Ea2011AF91cF8711][_spender] = _value;
        Approval(0x774F6B8302213946165c10F6Ea2011AF91cF8711, _spender, _value);
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), 0x774F6B8302213946165c10F6Ea2011AF91cF8711, _value, this, _extraData)) { throw; }
        return true;
    }
}
