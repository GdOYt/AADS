contract TrueToken is Standard223Token {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public INITIAL_SUPPLY = 25000000;    
    function TrueToken() public {
        name = "TRUE";
        symbol = "TRUE";
        decimals = 18;
        totalSupply_ = INITIAL_SUPPLY * 10 ** uint256(decimals);
        balances[msg.sender] = totalSupply_;
    }
}
