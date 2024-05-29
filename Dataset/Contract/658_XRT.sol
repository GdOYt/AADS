contract XRT is MintableToken, BurnableToken {
    string public constant name     = "Robonomics Beta";
    string public constant symbol   = "XRT";
    uint   public constant decimals = 9;
    uint256 public constant INITIAL_SUPPLY = 1000 * (10 ** uint256(decimals));
    constructor() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);
    }
}
