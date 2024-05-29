contract YunMint is Operational, ReentrancyGuard, BurnableToken, StandardToken {
    using SafeMath for uint;
    using SafeMath for uint256;
    using DateTime for uint256;
    event Release(address operator, uint256 value, uint256 releaseTime);
    event Burn(address indexed burner, uint256 value);
    event Freeze(address indexed owner, uint256 value, uint256 releaseTime);
    event Unfreeze(address indexed owner, uint256 value, uint256 releaseTime);
    struct FrozenBalance {address owner; uint256 value; uint256 unFrozenTime;}
    mapping (uint => FrozenBalance) public frozenBalances;
    uint public frozenBalanceCount = 0;
    uint256 constant valueTotal = 303000000 * (10 ** 8);
    uint256 public releasedSupply;
    uint    public releasedCount = 0;
    uint    public cycleCount = 0;
    uint256 public firstReleaseAmount;
    uint256 public curReleaseAmount;
    uint256 public createTime = 0;
    uint256 public lastReleaseTime = 0;
    modifier validAddress(address _address) {
        assert(0x0 != _address);
        _;
    }
    function YunMint(address _operator) public validAddress(_operator) Operational(_operator) {
        createTime = block.timestamp;
        totalSupply_ = valueTotal;
        firstReleaseAmount = 200000 * (10 ** 8);
    }
    function batchTransfer(address[] _to, uint256[] _amount) public returns(bool success) {
        for(uint i = 0; i < _to.length; i++){
            require(transfer(_to[i], _amount[i]));
        }
        return true;
    }
    function release(uint256 timestamp) public onlyOperator returns(bool) {
        require(timestamp <= block.timestamp);
        if(lastReleaseTime > 0){
            require(timestamp > lastReleaseTime);
        }
        require(!hasItBeenReleased(timestamp));
        cycleCount = releasedCount.div(30);
        require(cycleCount < 100);
        require(releasedSupply < valueTotal);
        curReleaseAmount = firstReleaseAmount - (cycleCount * 2000 * (10 ** 8));
        balances[owner] = balances[owner].add(curReleaseAmount);
        releasedSupply = releasedSupply.add(curReleaseAmount);
        lastReleaseTime = timestamp;
        releasedCount = releasedCount + 1;
        emit Release(msg.sender, curReleaseAmount, lastReleaseTime);
        emit Transfer(address(0), owner, curReleaseAmount);
        return true;
    }
    function hasItBeenReleased(uint256 timestamp) internal view returns(bool _exist) {
        bool exist = false;
        if ((lastReleaseTime.parseTimestamp().year == timestamp.parseTimestamp().year)
            && (lastReleaseTime.parseTimestamp().month == timestamp.parseTimestamp().month)
            && (lastReleaseTime.parseTimestamp().day == timestamp.parseTimestamp().day)) {
            exist = true;
        }
        return exist;
    }
    function freeze(uint256 _value, uint256 _unFrozenTime) nonReentrant public returns (bool) {
        require(balances[msg.sender] >= _value);
        require(_unFrozenTime > createTime);
        require(_unFrozenTime > block.timestamp);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        frozenBalances[frozenBalanceCount] = FrozenBalance({owner: msg.sender, value: _value, unFrozenTime: _unFrozenTime});
        frozenBalanceCount++;
        emit Freeze(msg.sender, _value, _unFrozenTime);
        return true;
    }
    function frozenBalanceOf(address _owner) constant public returns (uint256 value) {
        for (uint i = 0; i < frozenBalanceCount; i++) {
            FrozenBalance storage frozenBalance = frozenBalances[i];
            if (_owner == frozenBalance.owner) {
                value = value.add(frozenBalance.value);
            }
        }
        return value;
    }
    function unfreeze() public returns (uint256 releaseAmount) {
        uint index = 0;
        while (index < frozenBalanceCount) {
            if (now >= frozenBalances[index].unFrozenTime) {
                releaseAmount += frozenBalances[index].value;
                unFrozenBalanceByIndex(index);
            } else {
                index++;
            }
        }
        return releaseAmount;
    }
    function unFrozenBalanceByIndex(uint index) internal {
        FrozenBalance storage frozenBalance = frozenBalances[index];
        balances[frozenBalance.owner] = balances[frozenBalance.owner].add(frozenBalance.value);
        emit Unfreeze(frozenBalance.owner, frozenBalance.value, frozenBalance.unFrozenTime);
        frozenBalances[index] = frozenBalances[frozenBalanceCount - 1];
        delete frozenBalances[frozenBalanceCount - 1];
        frozenBalanceCount--;
    }
}
