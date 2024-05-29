contract TestTokenTen is StandardToken {
    function () {
        revert();
    }
    string public name;                    
    string public symbol;                  
    string public version = 'H1.0';        
    address private _owner;
    string public feeInfo = "Each operation costs 1% of the transaction amount, but not more than 250 tokens.";
    function TestTokenTen() {
        _totalSupply = 800000000000000000000000000; 
        _owner=msg.sender;
        balances[msg.sender] =_totalSupply;
        allocate(0x5feD3A18Df4ac9a1e6F767fB47889B04Ee4805f8,55);  
        allocate(0x077C3f919130282001e88A5fDbA45aA0230a0190,20);  
        allocate(0x7489D3112D515008ae61d8c5c08D788F90b66dd2,20);  
        allocate(0x15D4EEB0a8b695d7a9A8B7eDBA94A1F65Be1aBE6,5);  
        maxFee=250;  
        name = "TestToken10";                              
        decimals = 18;                                   
        symbol = "TT10";                                
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
