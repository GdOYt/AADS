contract TokenVestingFactory is Claimable {
    event Created(VariableRateTokenVesting vesting);
    function create(
        address _beneficiary,
        uint256 _start,
        uint256[] _cumulativeRates,
        uint256 _interval
    ) onlyOwner public returns (VariableRateTokenVesting)
    {
        VariableRateTokenVesting vesting = new VariableRateTokenVesting(
            _beneficiary, _start, _cumulativeRates, _interval);
        emit Created(vesting);
        return vesting;
    }
}
