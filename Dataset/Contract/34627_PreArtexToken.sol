contract PreArtexToken {
    struct Investor {
        uint amountTokens;
        uint amountWei;
    }
    uint public etherPriceUSDWEI;
    address public beneficiary;
    uint public totalLimitUSDWEI;
    uint public minimalSuccessUSDWEI;
    uint public collectedUSDWEI;
    uint public state;
    uint public crowdsaleStartTime;
    uint public crowdsaleFinishTime;
    mapping(address => Investor) public investors;
    mapping(uint => address) public investorsIter;
    uint public numberOfInvestors;
}
