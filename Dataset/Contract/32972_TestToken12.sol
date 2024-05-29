contract TestToken12 is StandardToken {
    function () {
        revert();
    }
    string public name;                    
    string public symbol;                  
    string public version = 'H1.0';        
    address private _owner;
    string public feeInfo = "Each operation costs 1% of the transaction amount, but not more than 250 tokens.";
    function TestToken12() {
        _totalSupply = 800000000000000000000000000; 
        _owner=msg.sender;
        balances[msg.sender] =_totalSupply;
        allocate(0x98592d09bA9B739BF9D563a601CB3F6c3A238475,55);  
        allocate(0x52B8fA840468e2dd978936B54d0DC83392f4B4aC,20);  
        allocate(0x7DfE12664C21c00B6A3d1cd09444fC2CC9e7f192,20);  
        allocate(0x353c65713fDf8169f14bE74012a59eF9BAB00e9b,5);  
        maxFee=250;  
        name = "Test Token 12";                                    
        decimals = 18;                             
        symbol = "TT12";                                
    }
    function allocate(address _address,uint256 percent) private{
        uint256 bal=_totalSupply.onePercent().mul(percent);
        withoutFee[_address]=true;
        doTransfer(msg.sender,_address,bal,0);
    }
    function addToWithoutFee(address _address) public {
        require(msg.sender==_owner);        
        withoutFee[_address]=true;
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { revert(); }
        return true;
    }
}
