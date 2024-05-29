contract ECToken is EroStandardToken {
    uint256 constant public decimals = 8;  
    uint256 public totalSupply = 24 * (10**7) * 10**8 ;  
    string constant public name = "ECToken";  
    string constant public symbol = "EC";  
    string constant public version = "v1.1.5";        
    function ECToken(){
        balances[msg.sender] = totalSupply;                
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
    }
}
