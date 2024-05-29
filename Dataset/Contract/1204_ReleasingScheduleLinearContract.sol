contract ReleasingScheduleLinearContract {
    using SafeMath for uint256;
    uint256 public startTime;
    uint256 public tickDuration;
    uint256 public amountPerTick;
    function ReleasingScheduleLinearContract(uint256 _startTime, uint256 _tickDuration, uint256 _amountPerTick) public{
        startTime = _startTime;
        tickDuration = _tickDuration;
        amountPerTick = _amountPerTick;
    }
    function getReleasableFunds(address _vesting) public view returns (uint256){
        TokenVestingContract vesting = TokenVestingContract(_vesting);
        uint256 balance = ERC20TokenInterface(vesting.tokenAddress()).balanceOf(_vesting);
        if (balance == 0 || (startTime >= now)) {
            return 0;
        }
        uint256 vestingScheduleAmount = (now.sub(startTime) / tickDuration) * amountPerTick;
        uint256 releasableFunds = vestingScheduleAmount.sub(vesting.alreadyReleasedAmount());
        if (releasableFunds > balance) {
            releasableFunds = balance;
        }
        return releasableFunds;
    }
}
