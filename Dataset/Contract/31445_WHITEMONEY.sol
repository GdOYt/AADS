contract WHITEMONEY is WCOStandardToken {
    uint256 constant public decimals = 8;
    uint256 public totalSupply = 20 * (10**7) * 10**8 ;  
    string constant public name = "White Money";
    string constant public symbol = "WCO";
    function WHITEMONEY(){
        balances[msg.sender] = totalSupply;                
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
    }
}