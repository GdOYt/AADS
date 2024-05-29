contract GotToken is CanReclaimToken, MintableToken, PausableToken, BurnableToken {
    string public constant name = "GOToken";
    string public constant symbol = "GOT";
    uint8 public constant decimals = 18;
    constructor() public {
        paused = true;
    }
}
