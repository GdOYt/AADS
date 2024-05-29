contract MuskTokenVault is Ownable {
    using SafeMath for uint256;
    address public teamReserveWallet = 0xBf7E6DC9317dF0e9Fde7847577154e6C5114370d;
    address public finalReserveWallet = 0xBf7E6DC9317dF0e9Fde7847577154e6C5114370d;
    uint256 public teamReserveAllocation = 240 * (10 ** 6) * (10 ** 18);
    uint256 public finalReserveAllocation = 10 * (10 ** 6) * (10 ** 18);
    uint256 public totalAllocation = 250 * (10 ** 6) * (10 ** 18);
    uint256 public teamTimeLock = 2 * 365 days;
    uint256 public teamVestingStages = 8;
    uint256 public finalReserveTimeLock = 2 * 365 days;
    mapping(address => uint256) public allocations;
    mapping(address => uint256) public timeLocks;
    mapping(address => uint256) public claimed;
    uint256 public lockedAt = 0;
    MuskToken public token;
    event Allocated(address wallet, uint256 value);
    event Distributed(address wallet, uint256 value);
    event Locked(uint256 lockTime);
    modifier onlyReserveWallets {
        require(allocations[msg.sender] > 0);
        _;
    }
    modifier onlyTeamReserve {
        require(msg.sender == teamReserveWallet);
        require(allocations[msg.sender] > 0);
        _;
    }
    modifier onlyTokenReserve {
        require(msg.sender == finalReserveWallet);
        require(allocations[msg.sender] > 0);
        _;
    }
    modifier notLocked {
        require(lockedAt == 0);
        _;
    }
    modifier locked {
        require(lockedAt > 0);
        _;
    }
    modifier notAllocated {
        require(allocations[teamReserveWallet] == 0);
        require(allocations[finalReserveWallet] == 0);
        _;
    }
    function MuskTokenVault(Token _token) public {
        owner = msg.sender;
        token = MuskToken(_token);
    }
    function allocate() public notLocked notAllocated onlyOwner {
        require(token.balanceOf(address(this)) == totalAllocation);
        allocations[teamReserveWallet] = teamReserveAllocation;
        allocations[finalReserveWallet] = finalReserveAllocation;
        Allocated(teamReserveWallet, teamReserveAllocation);
        Allocated(finalReserveWallet, finalReserveAllocation);
        lock();
    }
    function lock() internal notLocked onlyOwner {
        lockedAt = block.timestamp;
        timeLocks[teamReserveWallet] = lockedAt.add(teamTimeLock);
        timeLocks[finalReserveWallet] = lockedAt.add(finalReserveTimeLock);
        Locked(lockedAt);
    }
    function recoverFailedLock() external notLocked notAllocated onlyOwner {
        require(token.transfer(owner, token.balanceOf(address(this))));
    }
    function getTotalBalance() public view returns (uint256 tokensCurrentlyInVault) {
        return token.balanceOf(address(this));
    }
    function getLockedBalance() public view onlyReserveWallets returns (uint256 tokensLocked) {
        return allocations[msg.sender].sub(claimed[msg.sender]);
    }
    function claimTokenReserve() onlyTokenReserve locked public {
        address reserveWallet = msg.sender;
        require(block.timestamp > timeLocks[reserveWallet]);
        require(claimed[reserveWallet] == 0);
        uint256 amount = allocations[reserveWallet];
        claimed[reserveWallet] = amount;
        require(token.transfer(reserveWallet, amount));
        Distributed(reserveWallet, amount);
    }
    function claimTeamReserve() onlyTeamReserve locked public {
        uint256 vestingStage = teamVestingStage();
        uint256 totalUnlocked = vestingStage.mul(allocations[teamReserveWallet]).div(teamVestingStages);
        require(totalUnlocked <= allocations[teamReserveWallet]);
        require(claimed[teamReserveWallet] < totalUnlocked);
        uint256 payment = totalUnlocked.sub(claimed[teamReserveWallet]);
        claimed[teamReserveWallet] = totalUnlocked;
        require(token.transfer(teamReserveWallet, payment));
        Distributed(teamReserveWallet, payment);
    }
    function teamVestingStage() public view onlyTeamReserve returns(uint256){
        uint256 vestingMonths = teamTimeLock.div(teamVestingStages); 
        uint256 stage = (block.timestamp.sub(lockedAt)).div(vestingMonths);
        if(stage > teamVestingStages){
            stage = teamVestingStages;
        }
        return stage;
    }
    function canCollect() public view onlyReserveWallets returns(bool) {
        return block.timestamp > timeLocks[msg.sender] && claimed[msg.sender] == 0;
    }
}
