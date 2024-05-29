contract Tokenlock is Ownable {
    using SafeERC20 for ERC20;
    event LockStarted(uint256 now, uint256 interval);
    event TokenLocked(address indexed buyer, uint256 amount);
    event TokenReleased(address indexed buyer, uint256 amount);
    mapping (address => uint256) public buyers;
    address public locker;
    address public distributor;
    ERC20 public Token;
    bool public started = false;
    uint256 public interval;
    uint256 public releaseTime;
    constructor(address token, uint256 time) public {
        require(token != address(0));
        Token = ERC20(token);
        interval = time;
        locker = owner;
        distributor = owner;
    }
    function setLocker(address addr)
        external
        onlyOwner
    {
        require(addr != address(0));
        locker = addr;
    }
    function setDistributor(address addr)
        external
        onlyOwner
    {
        require(addr != address(0));
        distributor = addr;
    }
    function lock(address beneficiary, uint256 amount)
        external
    {
        require(msg.sender == locker);
        require(beneficiary != address(0));
        buyers[beneficiary] += amount;
        emit TokenLocked(beneficiary, buyers[beneficiary]);
    }
    function start()
        external
        onlyOwner
    {
        require(!started);
        started = true;
        releaseTime = block.timestamp + interval;
        emit LockStarted(block.timestamp, interval);
    }
    function release(address beneficiary)
        external
    {
        require(msg.sender == distributor);
        require(started);
        require(block.timestamp >= releaseTime);
        uint256 amount = buyers[beneficiary];
        buyers[beneficiary] = 0;
        Token.safeTransfer(beneficiary, amount);
        emit TokenReleased(beneficiary, amount);
    }
    function withdraw() public onlyOwner {
        require(block.timestamp >= releaseTime);
        Token.safeTransfer(owner, Token.balanceOf(address(this)));
    }
    function close() external onlyOwner {
        withdraw();
        selfdestruct(owner);
    }
}
