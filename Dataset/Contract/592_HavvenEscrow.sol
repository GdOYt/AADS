contract HavvenEscrow is SafeDecimalMath, Owned, LimitedSetup(8 weeks) {
    Havven public havven;
    mapping(address => uint[2][]) public vestingSchedules;
    mapping(address => uint) public totalVestedAccountBalance;
    uint public totalVestedBalance;
    uint constant TIME_INDEX = 0;
    uint constant QUANTITY_INDEX = 1;
    uint constant MAX_VESTING_ENTRIES = 20;
    constructor(address _owner, Havven _havven)
        Owned(_owner)
        public
    {
        havven = _havven;
    }
    function setHavven(Havven _havven)
        external
        onlyOwner
    {
        havven = _havven;
        emit HavvenUpdated(_havven);
    }
    function balanceOf(address account)
        public
        view
        returns (uint)
    {
        return totalVestedAccountBalance[account];
    }
    function numVestingEntries(address account)
        public
        view
        returns (uint)
    {
        return vestingSchedules[account].length;
    }
    function getVestingScheduleEntry(address account, uint index)
        public
        view
        returns (uint[2])
    {
        return vestingSchedules[account][index];
    }
    function getVestingTime(address account, uint index)
        public
        view
        returns (uint)
    {
        return getVestingScheduleEntry(account,index)[TIME_INDEX];
    }
    function getVestingQuantity(address account, uint index)
        public
        view
        returns (uint)
    {
        return getVestingScheduleEntry(account,index)[QUANTITY_INDEX];
    }
    function getNextVestingIndex(address account)
        public
        view
        returns (uint)
    {
        uint len = numVestingEntries(account);
        for (uint i = 0; i < len; i++) {
            if (getVestingTime(account, i) != 0) {
                return i;
            }
        }
        return len;
    }
    function getNextVestingEntry(address account)
        public
        view
        returns (uint[2])
    {
        uint index = getNextVestingIndex(account);
        if (index == numVestingEntries(account)) {
            return [uint(0), 0];
        }
        return getVestingScheduleEntry(account, index);
    }
    function getNextVestingTime(address account)
        external
        view
        returns (uint)
    {
        return getNextVestingEntry(account)[TIME_INDEX];
    }
    function getNextVestingQuantity(address account)
        external
        view
        returns (uint)
    {
        return getNextVestingEntry(account)[QUANTITY_INDEX];
    }
    function withdrawHavvens(uint quantity)
        external
        onlyOwner
        onlyDuringSetup
    {
        havven.transfer(havven, quantity);
    }
    function purgeAccount(address account)
        external
        onlyOwner
        onlyDuringSetup
    {
        delete vestingSchedules[account];
        totalVestedBalance = safeSub(totalVestedBalance, totalVestedAccountBalance[account]);
        delete totalVestedAccountBalance[account];
    }
    function appendVestingEntry(address account, uint time, uint quantity)
        public
        onlyOwner
        onlyDuringSetup
    {
        require(now < time, "Time must be in the future");
        require(quantity != 0, "Quantity cannot be zero");
        totalVestedBalance = safeAdd(totalVestedBalance, quantity);
        require(totalVestedBalance <= havven.balanceOf(this), "Must be enough balance in the contract to provide for the vesting entry");
        uint scheduleLength = vestingSchedules[account].length;
        require(scheduleLength <= MAX_VESTING_ENTRIES, "Vesting schedule is too long");
        if (scheduleLength == 0) {
            totalVestedAccountBalance[account] = quantity;
        } else {
            require(getVestingTime(account, numVestingEntries(account) - 1) < time, "Cannot add new vested entries earlier than the last one");
            totalVestedAccountBalance[account] = safeAdd(totalVestedAccountBalance[account], quantity);
        }
        vestingSchedules[account].push([time, quantity]);
    }
    function addVestingSchedule(address account, uint[] times, uint[] quantities)
        external
        onlyOwner
        onlyDuringSetup
    {
        for (uint i = 0; i < times.length; i++) {
            appendVestingEntry(account, times[i], quantities[i]);
        }
    }
    function vest()
        external
    {
        uint numEntries = numVestingEntries(msg.sender);
        uint total;
        for (uint i = 0; i < numEntries; i++) {
            uint time = getVestingTime(msg.sender, i);
            if (time > now) {
                break;
            }
            uint qty = getVestingQuantity(msg.sender, i);
            if (qty == 0) {
                continue;
            }
            vestingSchedules[msg.sender][i] = [0, 0];
            total = safeAdd(total, qty);
        }
        if (total != 0) {
            totalVestedBalance = safeSub(totalVestedBalance, total);
            totalVestedAccountBalance[msg.sender] = safeSub(totalVestedAccountBalance[msg.sender], total);
            havven.transfer(msg.sender, total);
            emit Vested(msg.sender, now, total);
        }
    }
    event HavvenUpdated(address newHavven);
    event Vested(address indexed beneficiary, uint time, uint value);
}
