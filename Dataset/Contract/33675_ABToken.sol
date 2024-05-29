contract ABToken is ABStandardToken {
    string public name;                    
    uint8 public decimals;                 
    string public symbol;                  
    string public version = 'H0.1.1';        
     function ABToken() public {
        totalSupply = 990000000;
        balances[msg.sender] = totalSupply;  
        decimals = 4;
        name = "Pablo Token";
        symbol = "PAB";
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        require(_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
    }
}
