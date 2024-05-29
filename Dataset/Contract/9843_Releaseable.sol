contract Releaseable is Frozenable {
    using SafeMath for uint;
    uint256 public createTime;
    uint256 public standardReleaseAmount = mulDecimals.mul(512000);  
    uint256 public releaseAmountPerDay = mulDecimals.mul(512000);
    uint256 public releasedSupply = 0;
    event Release(address indexed receiver, uint256 value, uint256 sysAmount, uint256 releaseTime);
    struct ReleaseRecord {
        uint256 amount;  
        uint256 releaseIndex;  
    }
    mapping (uint256 => ReleaseRecord) public releaseRecords;
    function Releaseable(
                    address _operator, uint256 _initialSupply
                ) Frozenable(_operator) public {
        createTime = 1529078400;
        releasedSupply = _initialSupply;
        balances[owner] = _initialSupply;
        totalSupply_ = mulDecimals.mul(187140000);
    }
    function release(uint256 timestamp, uint256 sysAmount) public onlyOperator returns(uint256 _actualRelease) {
        require(timestamp >= createTime && timestamp <= block.timestamp);
        require(!checkIsReleaseRecordExist(timestamp));
        updateReleaseAmount(timestamp);
        require(sysAmount <= releaseAmountPerDay.mul(4).div(5));
        require(totalSupply_ >= releasedSupply.add(releaseAmountPerDay));
        balances[owner] = balances[owner].add(releaseAmountPerDay);
        releasedSupply = releasedSupply.add(releaseAmountPerDay);
        uint256 _releaseIndex = uint256(timestamp.parseTimestamp().year) * 10000 + uint256(timestamp.parseTimestamp().month) * 100 + uint256(timestamp.parseTimestamp().day);
        releaseRecords[_releaseIndex] = ReleaseRecord(releaseAmountPerDay, _releaseIndex);
        emit Release(owner, releaseAmountPerDay, sysAmount, timestamp);
        systemFreeze(sysAmount.div(5), timestamp.add(180 days));
        systemFreeze(sysAmount.mul(6).div(10), timestamp.add(200 years));
        return releaseAmountPerDay;
    }
    function checkIsReleaseRecordExist(uint256 timestamp) internal view returns(bool _exist) {
        bool exist = false;
        uint256 releaseIndex = uint256(timestamp.parseTimestamp().year) * 10000 + uint256(timestamp.parseTimestamp().month) * 100 + uint256(timestamp.parseTimestamp().day);
        if (releaseRecords[releaseIndex].releaseIndex == releaseIndex){
            exist = true;
        }
        return exist;
    }
    function updateReleaseAmount(uint256 timestamp) internal {
        uint256 timeElapse = timestamp.sub(createTime);
        uint256 cycles = timeElapse.div(180 days);
        if (cycles > 0) {
            if (cycles <= 10) {
                releaseAmountPerDay = standardReleaseAmount;
                for (uint index = 0; index < cycles; index++) {
                    releaseAmountPerDay = releaseAmountPerDay.div(2);
                }
            } else {
                releaseAmountPerDay = 0;
            }
        }
    }
}
