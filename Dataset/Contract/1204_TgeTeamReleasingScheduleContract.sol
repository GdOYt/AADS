contract TgeTeamReleasingScheduleContract {
    uint256 constant releaseDate = 1578873600;
    function TgeTeamReleasingScheduleContract() public {}
    function getReleasableFunds(address _vesting) public view returns (uint256) {
        TokenVestingContract vesting = TokenVestingContract(_vesting);
        if (releaseDate >= now) {
            return 0;
        } else {
            return vesting.getTokenBalance();
        }
    }
}
