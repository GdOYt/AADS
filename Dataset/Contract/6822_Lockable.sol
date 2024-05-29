contract Lockable is Ownable, SafeMath {
    mapping (address => uint256) balances;
    mapping (address => uint256) totalbalances;
    uint256 public totalreleaseblances;
    mapping (address => mapping (uint256 => uint256)) userbalances;  
    mapping (address => mapping (uint256 => uint256)) userRelease;  
    mapping (address => mapping (uint256 => uint256)) isRelease;  
    mapping (address => mapping (uint256 => uint256)) userChargeTime;  
    mapping (address => uint256) userChargeCount;  
    mapping (address => mapping (uint256 => uint256)) lastCliff;  
    mapping (address => mapping (uint256 => mapping (uint256 => uint256))) userbalancesSegmentation;  
    uint256 internal duration = 30*15 days;
    uint256 internal cliff = 90 days;
    event userlockmechanism(address _addr,uint256 _amount,uint256 _timestamp);
    event userrelease(address _addr, uint256 _times, uint256 _amount);
    modifier onlySelfOrOwner(address _addr) {
        require(msg.sender == _addr || msg.sender == ethFundDeposit);
        _;
    }
    function LockMechanism (
        address _addr,
        uint256 _value
    )
        internal
    {
        require(_addr != address(0));
        require(_value != 0);
        userChargeCount[_addr] = safeAdd(userChargeCount[_addr],1);
        uint256 _times = userChargeCount[_addr];
        userChargeTime[_addr][_times] = ShowTime();
        userbalances[_addr][_times] = _value;
        initsegmentation(_addr,userChargeCount[_addr],_value);
        totalbalances[_addr] = safeAdd(totalbalances[_addr],_value);
        isRelease[_addr][_times] = 0;
        emit userlockmechanism(_addr,_value,ShowTime());
    }
    function initsegmentation(address _addr,uint256 _times,uint256 _value) internal {
        for (uint8 i = 1 ; i <= 5 ; i++ ) {
            userbalancesSegmentation[_addr][_times][i] = safeDiv(_value,5);
        }
    }
    function CalcPeriod(address _addr, uint256 _times) public view returns (uint256) {
        uint256 userstart = userChargeTime[_addr][_times];
        if (ShowTime() >= safeAdd(userstart,duration)) {
            return 5;
        }
        uint256 timedifference = safeSubtract(ShowTime(),userstart);
        uint256 period = 0;
        for (uint8 i = 1 ; i <= 5 ; i++ ) {
            if (timedifference >= cliff) {
                timedifference = safeSubtract(timedifference,cliff);
                period += 1;
            }
        }
        return period;
    }
    function ReleasableAmount(address _addr, uint256 _times) public view returns (uint256) {
        require(_addr != address(0));
        uint256 period = CalcPeriod(_addr,_times);
        if (safeSubtract(period,isRelease[_addr][_times]) > 0){
            uint256 amount = 0;
            for (uint256 i = safeAdd(isRelease[_addr][_times],1) ; i <= period ; i++ ) {
                amount = safeAdd(amount,userbalancesSegmentation[_addr][_times][i]);
            }
            return amount;
        } else {
            return 0;
        }
    }
    function release(address _addr, uint256 _times) external onlySelfOrOwner(_addr) {
        uint256 amount = ReleasableAmount(_addr,_times);
        require(amount > 0);
        userRelease[_addr][_times] = safeAdd(userRelease[_addr][_times],amount);
        balances[_addr] = safeAdd(balances[_addr],amount);
        lastCliff[_addr][_times] = ShowTime();
        isRelease[_addr][_times] = CalcPeriod(_addr,_times);
        totalreleaseblances = safeAdd(totalreleaseblances,amount);
        emit userrelease(_addr, _times, amount);
    }
    function ShowTime() internal view returns (uint256) {
        return block.timestamp;
    }
    function totalBalanceOf(address _addr) public view returns (uint256) {
        return totalbalances[_addr];
    }
    function ShowRelease(address _addr, uint256 _times) public view returns (uint256) {
        return userRelease[_addr][_times];
    }
    function ShowUnrelease(address _addr, uint256 _times) public view returns (uint256) {
        return safeSubtract(userbalances[_addr][_times],ShowRelease(_addr,_times));
    }
    function ShowChargeTime(address _addr, uint256 _times) public view returns (uint256) {
        return userChargeTime[_addr][_times];
    }
    function ShowChargeCount(address _addr) public view returns (uint256) {
        return userChargeCount[_addr];
    }
    function ShowNextCliff(address _addr, uint256 _times) public view returns (uint256) {
        return safeAdd(lastCliff[_addr][_times],cliff);
    }
    function ShowSegmentation(address _addr, uint256 _times,uint256 _period) public view returns (uint256) {
        return userbalancesSegmentation[_addr][_times][_period];
    }
}
