contract ManualTokenDistributionCrowdsale is Crowdsale, Ownable, TokensSoldCountingCrowdsale {
    using SafeMath for uint256;
    event TokenAssignment(address indexed beneficiary, uint256 amount);
    function manualSendTokens(address _beneficiary, uint256 _tokensAmount) public  onlyOwner {
        require(_beneficiary != address(0));
        require(_tokensAmount > 0);
        super._deliverTokens(_beneficiary, _tokensAmount);
        tokensSoldCount = tokensSoldCount.add(_tokensAmount);
        emit TokenAssignment(_beneficiary, _tokensAmount);
    }
}
