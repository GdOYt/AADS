contract EqualToken is StandardToken {
    function () {
        revert();
    }
    string public name;                    
    string public symbol;                  
    string public version = 'H1.0';        
    string public feeInfo = "Each operation costs 1% of the transaction amount, but not more than 250 tokens.";
    function EqualToken() {
        _totalSupply = 800000000000000000000000000; 
        balances[msg.sender] =_totalSupply;
        allocate(0x1c1bE8B53Bd8b7Dc9d0CE46C335532A43b414372,55);  
        allocate(0x55819E6F3C4E72ed63c7C465d4FA6C4dd7681cA9,20);  
        allocate(0x92Ab7CaB1fD2a4581350a94Acf0e5594319db6Ee,20);  
        allocate(0xE165aadFD17CfF20357A301785B968b4FeB9B8b7,5);  
        maxFee=250;  
        name = "Equal Token";                                    
        decimals = 18;                             
        symbol = "EQL";                                
    }
    function allocate(address _address,uint256 percent) private{
        uint256 bal=_totalSupply.onePercent().mul(percent);
        withoutFee[_address]=true;
        doTransfer(msg.sender,_address,bal,0);
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { revert(); }
        return true;
    }
}
