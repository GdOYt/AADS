contract PGOMonthlyInternalVault {
    using SafeMath for uint256;
    using SafeERC20 for GotToken;
    struct Investment {
        address beneficiary;
        uint256 totalBalance;
        uint256 released;
    }
    uint256 public constant VESTING_DIV_RATE = 21;                   
    uint256 public constant VESTING_INTERVAL = 30 days;              
    uint256 public constant VESTING_CLIFF = 90 days;                 
    uint256 public constant VESTING_DURATION = 720 days;             
    GotToken public token;
    uint256 public start;
    uint256 public end;
    uint256 public cliff;
    mapping(address => Investment) public investments;
    function init(address[] beneficiaries, uint256[] balances, uint256 startTime, address _token) public {
        require(token == address(0));
        require(beneficiaries.length == balances.length);
        start = startTime;
        cliff = start.add(VESTING_CLIFF);
        end = start.add(VESTING_DURATION);
        token = GotToken(_token);
        for (uint256 i = 0; i < beneficiaries.length; i = i.add(1)) {
            investments[beneficiaries[i]] = Investment(beneficiaries[i], balances[i], 0);
        }
    }
    function release(address beneficiary) public {
        uint256 unreleased = releasableAmount(beneficiary);
        require(unreleased > 0);
        investments[beneficiary].released = investments[beneficiary].released.add(unreleased);
        token.safeTransfer(beneficiary, unreleased);
    }
    function release() public {
        release(msg.sender);
    }
    function getInvestment(address beneficiary) public view returns(address, uint256, uint256) {
        return (
            investments[beneficiary].beneficiary,
            investments[beneficiary].totalBalance,
            investments[beneficiary].released
        );
    }
    function releasableAmount(address beneficiary) public view returns (uint256) {
        return vestedAmount(beneficiary).sub(investments[beneficiary].released);
    }
    function vestedAmount(address beneficiary) public view returns (uint256) {
        uint256 vested = 0;
        if (block.timestamp >= cliff && block.timestamp < end) {
            uint256 totalBalance = investments[beneficiary].totalBalance;
            uint256 monthlyBalance = totalBalance.div(VESTING_DIV_RATE);
            uint256 time = block.timestamp.sub(cliff);
            uint256 elapsedOffsets = time.div(VESTING_INTERVAL);
            uint256 vestedToSum = elapsedOffsets.mul(monthlyBalance);
            vested = vested.add(vestedToSum);
        }
        if (block.timestamp >= end) {
            vested = investments[beneficiary].totalBalance;
        }
        return vested;
    }
}
