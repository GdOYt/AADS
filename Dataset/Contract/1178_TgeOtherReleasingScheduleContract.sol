contract TgeOtherReleasingScheduleContract is ReleasingScheduleLinearContract {
    uint256 constant releaseDate = 1578873600;
    uint256 constant monthLength = 2592000;
    function TgeOtherReleasingScheduleContract(uint256 _amount, uint256 _startTime) ReleasingScheduleLinearContract(_startTime - monthLength, monthLength, _amount / 12) public {
    }
    function getReleasableFunds(address _vesting) public view returns (uint256) {
        if (now < releaseDate) {
            return 0;
        }
        return super.getReleasableFunds(_vesting);
    }
}
