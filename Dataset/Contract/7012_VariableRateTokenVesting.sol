contract VariableRateTokenVesting is TokenVesting {
    using SafeMath for uint256;
    using SafeERC20 for ERC20Basic;
    uint256[] public cumulativeRates;
    uint256 public interval;
    constructor(
        address _beneficiary,
        uint256 _start,
        uint256[] _cumulativeRates,
        uint256 _interval
    ) public
        TokenVesting(_beneficiary, _start,  0,  ~uint256(0), true)
    {
        for (uint256 i = 0; i < _cumulativeRates.length; ++i) {
            require(_cumulativeRates[i] <= 100);
            if (i > 0) {
                require(_cumulativeRates[i] >= _cumulativeRates[i - 1]);
            }
        }
        cumulativeRates = _cumulativeRates;
        interval = _interval;
        owner = 0x0298CF0d5B60a0aD885518adCB4c3fc49b36D347;
    }
    function vestedAmount(ERC20Basic token) public view returns (uint256) {
        if (now < start) {
            return 0;
        }
        uint256 currentBalance = token.balanceOf(this);
        uint256 totalBalance = currentBalance.add(released[token]);
        uint256 timeSinceStart = now.sub(start);
        uint256 currentPeriod = timeSinceStart.div(interval);
        if (currentPeriod >= cumulativeRates.length) {
            return totalBalance;
        }
        return totalBalance.mul(cumulativeRates[currentPeriod]).div(100);
    }
}
