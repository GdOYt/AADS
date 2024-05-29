contract WealthBuilderToken is MintableToken {
    string public name = "Wealth Builder Token";
    string public symbol = "WBT";
    uint32 public decimals = 18;
    uint public rate = 10**7;
    uint public mrate = 10**7;
    function setRate(uint _rate) onlyOwner public {
        rate = _rate;
    }
}
