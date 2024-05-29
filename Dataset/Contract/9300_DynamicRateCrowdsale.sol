contract DynamicRateCrowdsale is Crowdsale {
    using SafeMath for uint256;
    uint256 public bonusRate;
    constructor(uint256 _bonusRate) public {
        require(_bonusRate > 0);
        bonusRate = _bonusRate;
    }
    function getCurrentRate() public view returns (uint256) {
        return rate.add(bonusRate);
    }
    function _getTokenAmount(uint256 _weiAmount)
        internal view returns (uint256)
    {
        uint256 currentRate = getCurrentRate();
        return currentRate.mul(_weiAmount);
    }
}
