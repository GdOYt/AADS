contract PresaleOriginal is owned, ERC20 {
    uint    public totalLimitUSD;
    uint    public collectedUSD;
    uint    public presaleStartTime;
    struct Investor {
        uint256 amountTokens;
        uint    amountWei;
    }
    mapping (address => Investor) public investors;
    mapping (uint => address)     public investorsIter;
    uint                          public numberOfInvestors;
}
