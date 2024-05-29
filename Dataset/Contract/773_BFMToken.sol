contract BFMToken is StandardToken {
    string public constant name = "Blockchain and Fintech Media Union";
    string public constant symbol = "BFM"; 
    uint8 public constant decimals = 18; 
    uint256 public constant INITIAL_SUPPLY = 500 * (10 ** uint256(decimals));
    constructor() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);
    }
}
