contract EMIToken is StandardToken, MintableToken {
    string public name = "EMITOKEN";
    string public symbol = "EMI";
    uint8 public decimals = 8;
    uint256 public initialSupply = 600000000 * (10 ** uint256(decimals));
    function EMIToken() public{
        totalSupply = initialSupply;
        balances[msg.sender] = initialSupply;  
        emit Transfer(0x0, msg.sender, initialSupply);
    }
}
