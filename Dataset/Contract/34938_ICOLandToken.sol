contract ICOLandToken is ERC223TokenCompatible, StandardToken, StartToken, HumanStandardToken, BurnToken, OriginToken {
    uint8 public decimals = 18;
    string public name = "ICOLand";
    string public symbol = "ICL";
    uint256 public initialSupply;
    function ICOLandToken() public {
        totalSupply = 10000000 * 10 ** uint(decimals);  
        initialSupply = totalSupply;
        balances[msg.sender] = totalSupply;
    }
}
