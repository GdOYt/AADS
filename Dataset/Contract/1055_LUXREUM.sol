contract LUXREUM is LXRStandardToken {
    uint256 constant public decimals = 18;
    uint256 public totalSupply = 200 * (10**7) * 10**18 ;  
    string constant public name = "LUXREUM";
    string constant public symbol = "LXR";
    function LUXREUM(){
        balances[msg.sender] = totalSupply;                
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
    }
}
