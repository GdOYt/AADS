contract TokensSoldCountingCrowdsale is Crowdsale {
    using SafeMath for uint256;
    uint256 public tokensSoldCount;
    function _updatePurchasingState(
        address _beneficiary,
        uint256 _weiAmount
    )
    internal
    {
        uint256 tokens = _getTokenAmount(_weiAmount);
        tokensSoldCount = tokensSoldCount.add(tokens);
    }
}
