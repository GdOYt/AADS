contract FundsLocker {
    using SafeMath for uint;
    uint public lockTimeout;
    uint public totalTokenBalance;
    uint public latestTokenBalance;
    address public beneficiary;
    uint public vestingPeriod;
    BuddyToken public token;
    constructor(address _beneficiary,uint256 _start, uint256 _lockPeriod, uint _vestingPeriod,  BuddyToken _token) public {
        require(_beneficiary!=address(0));
        require(_start >= now);
        beneficiary = _beneficiary;
        lockTimeout = _start.add(_lockPeriod);
        vestingPeriod = _vestingPeriod;
        token = _token;
    }
    function () public {
        uint256 currentBalance = token.balanceOf(this);
        uint256 additionalTokens = currentBalance.sub(latestTokenBalance);
        totalTokenBalance = totalTokenBalance.add(additionalTokens);
        uint withdrawAmount = calculateSumToWithdraw();
        require(token.transfer(beneficiary, withdrawAmount));
        latestTokenBalance = token.balanceOf(this);
    }
    function calculateSumToWithdraw() public view returns (uint) {
        uint256 currentBalance = token.balanceOf(this);
        if(now<=lockTimeout) 
            return 0;
        if(now>lockTimeout.add(vestingPeriod))
            return currentBalance;
        uint256 minRequiredBalance = totalTokenBalance.sub(totalTokenBalance.mul(now.sub(lockTimeout)).div(vestingPeriod));
        if(minRequiredBalance > currentBalance)
            return 0;
        else 
            return currentBalance.sub(minRequiredBalance);
    }
}
