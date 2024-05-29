contract CTCLock is Ownable {
  using SafeMath for uint256;
  address public teamWallet;
  address public earlyWallet;
  address public institutionWallet;
  uint256 public teamTimeLock = 1000 days;
  uint256 public earlyTimeLock = 5 * 30 days;
  uint256 public institutionTimeLock = 50 * 30 days;
  uint256 public teamAllocation = 15 * (10 ** 7) * (10 ** 18);
  uint256 public earlyAllocation = 5 * (10 ** 7) * (10 ** 18);
  uint256 public institutionAllocation = 15 * (10 ** 7) * (10 ** 18);
  uint256 public totalAllocation = 35 * (10 ** 7) * (10 ** 18);
  uint256 public teamStageSetting = 34;
  uint256 public earlyStageSetting = 5;
  uint256 public institutionStageSetting = 50;
  ERC20Basic public token;
  uint256 public start;
  uint256 public lockStartTime; 
    mapping(address => uint256) public allocations;
    mapping(address => uint256) public stageSettings;
    mapping(address => uint256) public timeLockDurations;
    mapping(address => uint256) public releasedAmounts;
    modifier onlyReserveWallets {
        require(allocations[msg.sender] > 0);
        _;
    }
    function CTCLock(ERC20Basic _token,
                          address _teamWallet,
                          address _earlyWallet,
                          address _institutionWallet,
                          uint256 _start,
                          uint256 _lockTime)public{
        require(_start > 0);
        require(_lockTime > 0);
        require(_start.add(_lockTime) > 0);
        require(_teamWallet != address(0));
        require(_earlyWallet != address(0));
        require(_institutionWallet != address(0));
        token = _token;
        teamWallet = _teamWallet;
        earlyWallet = _earlyWallet;
        institutionWallet = _institutionWallet;
        start = _start;
        lockStartTime = start.add(_lockTime);
    }
    function allocateToken() onlyOwner public{
        require(block.timestamp > lockStartTime);
        require(allocations[teamWallet] == 0);
        require(token.balanceOf(address(this)) == totalAllocation);
        allocations[teamWallet] = teamAllocation;
        allocations[earlyWallet] = earlyAllocation;
        allocations[institutionWallet] = institutionAllocation;
        stageSettings[teamWallet] = teamStageSetting;
        stageSettings[earlyWallet] = earlyStageSetting;
        stageSettings[institutionWallet] = institutionStageSetting;
        timeLockDurations[teamWallet] = teamTimeLock;
        timeLockDurations[earlyWallet] = earlyTimeLock;
        timeLockDurations[institutionWallet] = institutionTimeLock;
    }
    function releaseToken() onlyReserveWallets public{
        uint256 totalUnlocked = unlockAmount();
        require(totalUnlocked <= allocations[msg.sender]);
        require(releasedAmounts[msg.sender] < totalUnlocked);
        uint256 payment = totalUnlocked.sub(releasedAmounts[msg.sender]);
        releasedAmounts[msg.sender] = totalUnlocked;
        require(token.transfer(msg.sender, payment));
    }
    function unlockAmount() public view onlyReserveWallets returns(uint256){
        uint256 stage = vestStage();
        uint256 totalUnlocked = stage.mul(allocations[msg.sender]).div(stageSettings[msg.sender]);
        return totalUnlocked;
    }
    function vestStage() public view onlyReserveWallets returns(uint256){
        uint256 vestingMonths = timeLockDurations[msg.sender].div(stageSettings[msg.sender]);
        uint256 stage = (block.timestamp.sub(lockStartTime)).div(vestingMonths);
        if(stage > stageSettings[msg.sender]){
            stage = stageSettings[msg.sender];
        }
        return stage;
    }
}
