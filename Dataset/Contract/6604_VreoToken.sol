contract VreoToken is CappedToken, PausableToken, BurnableToken {
    uint public constant TOTAL_TOKEN_CAP = 700000000e18;   
    string public name = "MERO Token";
    string public symbol = "MERO";
    uint8 public decimals = 18;
    constructor() public CappedToken(TOTAL_TOKEN_CAP) {
        pause();
    }
}
