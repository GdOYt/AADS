contract CappedStageCrowdsale is CappedCrowdsale, StageCrowdsale {
    using SafeMath for uint256;
    function weiToCap() public view returns (uint256) {
        return cap.sub(weiRaised);
    }
    function _postValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
        super._postValidatePurchase(_beneficiary, _weiAmount);
        if (weiRaised >= cap) {
            _finalizeStage();
        }
    }
}
