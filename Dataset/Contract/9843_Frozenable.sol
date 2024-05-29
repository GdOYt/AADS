contract Frozenable is Operational, StandardBurnableToken, ReentrancyGuard {
    using DateTime for uint256;
    struct FrozenRecord {
        uint256 value;
        uint256 unfreezeIndex;
    }
    uint256 public frozenBalance;
    mapping (uint256 => FrozenRecord) public frozenRecords;
    uint256 mulDecimals = 100000000;  
    event SystemFreeze(address indexed owner, uint256 value, uint256 unfreezeIndex);
    event Unfreeze(address indexed owner, uint256 value, uint256 unfreezeTime);
    function Frozenable(address _operator) Operational(_operator) public {}
    function systemFreeze(uint256 _value, uint256 _unfreezeTime) internal {
        uint256 unfreezeIndex = uint256(_unfreezeTime.parseTimestamp().year) * 10000 + uint256(_unfreezeTime.parseTimestamp().month) * 100 + uint256(_unfreezeTime.parseTimestamp().day);
        balances[owner] = balances[owner].sub(_value);
        frozenRecords[unfreezeIndex] = FrozenRecord({value: _value, unfreezeIndex: unfreezeIndex});
        frozenBalance = frozenBalance.add(_value);
        emit SystemFreeze(owner, _value, _unfreezeTime);
    }
    function unfreeze(uint256 timestamp) public returns (uint256 unfreezeAmount) {
        require(timestamp <= block.timestamp);
        uint256 unfreezeIndex = uint256(timestamp.parseTimestamp().year) * 10000 + uint256(timestamp.parseTimestamp().month) * 100 + uint256(timestamp.parseTimestamp().day);
        frozenBalance = frozenBalance.sub(frozenRecords[unfreezeIndex].value);
        balances[owner] = balances[owner].add(frozenRecords[unfreezeIndex].value);
        unfreezeAmount = frozenRecords[unfreezeIndex].value;
        emit Unfreeze(owner, unfreezeAmount, timestamp);
        frozenRecords[unfreezeIndex].value = 0;
        return unfreezeAmount;
    }
}
