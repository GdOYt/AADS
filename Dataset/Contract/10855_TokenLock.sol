contract TokenLock {
    using SafeMath for uint256;
	InseeCoin  public  ISC;      
    uint256 private nextLockID = 0;
    mapping (uint256 => TokenTimeLockInfo) public locks;
    struct TokenTimeLockInfo {
        address beneficiary;
        uint256 amount;
        uint256 unlockTime;
    }
    event Lock (uint256 indexed id, address indexed beneficiary,uint256 amount, uint256 lockTime);
    event Unlock (uint256 indexed id, address indexed beneficiary,uint256 amount, uint256 unlockTime);
	function TokenLock(InseeCoin isc) public {
        assert(address(isc) != address(0));
        ISC = isc;
	}
    function lock (
      address _beneficiary, uint256 _amount,
        uint256 _lockTime) public returns (uint256) {
        require (_amount > 0);
        require (_lockTime > 0);
        nextLockID = nextLockID.add(1);
        uint256 id = nextLockID;
        TokenTimeLockInfo storage lockInfo = locks [id];
        require (lockInfo.beneficiary == 0x0);
        require (lockInfo.amount == 0);
        require (lockInfo.unlockTime == 0);
        lockInfo.beneficiary = _beneficiary;
        lockInfo.amount = _amount;
        lockInfo.unlockTime =  now.add(_lockTime);
        emit Lock (id, _beneficiary, _amount, _lockTime);
        require (ISC.transferFrom (msg.sender, this, _amount));
        return id;
    }
    function unlock (uint256 _id) public {
        TokenTimeLockInfo memory lockInfo = locks [_id];
        delete locks [_id];
        require (lockInfo.amount > 0);
        require (lockInfo.unlockTime <= block.timestamp);
        emit Unlock (_id, lockInfo.beneficiary, lockInfo.amount, lockInfo.unlockTime);
        require (
            ISC.transfer (
                lockInfo.beneficiary, lockInfo.amount));
    }
}
