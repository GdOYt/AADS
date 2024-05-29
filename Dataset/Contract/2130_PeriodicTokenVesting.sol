contract PeriodicTokenVesting is TokenVesting {
    uint256 public periods;
    function PeriodicTokenVesting(
        address _beneficiary, uint256 _start, uint256 _cliff, uint256 _duration, uint256 _periods, bool _revocable
    )
        public TokenVesting(_beneficiary, _start, _cliff, _duration, _revocable)
    {
        periods = _periods;
    }
    function vestedAmount(ERC20Basic token) public view returns (uint256) {
        uint256 currentBalance = token.balanceOf(this);
        uint256 totalBalance = currentBalance.add(released[token]);
        if (now < cliff) {
            return 0;
        } else if (now >= start.add(duration * periods) || revoked[token]) {
            return totalBalance;
        } else {
            uint256 periodTokens = totalBalance.div(periods);
            uint256 periodsOver = now.sub(start).div(duration) + 1;
            if (periodsOver >= periods) {
                return totalBalance;
            }
            return periodTokens.mul(periodsOver);
        }
    }
}
