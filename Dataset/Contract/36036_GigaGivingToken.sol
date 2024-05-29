contract GigaGivingToken is StandardToken {
    string public constant NAME = "Giga Coin";
    string public constant SYMBOL = "GC";
    uint256 public constant DECIMALS = 0;
    uint256 public constant TOTAL_TOKENS = 15000000;
    uint256 public constant  CROWDSALE_TOKENS = 12000000;  
    string public constant VERSION = "GC.2";
    function GigaGivingToken () public {
        balances[msg.sender] = TOTAL_TOKENS; 
        totalSupply = TOTAL_TOKENS;
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
    }
}
