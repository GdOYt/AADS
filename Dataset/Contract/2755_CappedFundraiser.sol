contract CappedFundraiser is BasicFundraiser {
    uint256 public hardCap;
    function initializeCappedFundraiser(uint256 _hardCap) internal {
        require(_hardCap > 0);
        hardCap = _hardCap;
    }
    function validateTransaction() internal view {
        super.validateTransaction();
        require(totalRaised < hardCap);
    }
    function hasEnded() public view returns (bool) {
        return (super.hasEnded() || totalRaised >= hardCap);
    }
}
