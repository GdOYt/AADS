contract InitialTokenDistribution is Ownable {
    using SafeMath for uint256;
    ERC20 public token;
    mapping (address => TokenVesting) public vested;
    mapping (address => TokenTimelock) public timelocked;
    mapping (address => uint256) public initiallyDistributed;
    bool public initialDistributionDone = false;
    modifier onInitialDistribution() {
        require(!initialDistributionDone);
        _;
    }
    constructor(ERC20 _token) public {
        token = _token;
    }
    function initialDistribution() internal;
    function totalTokensDistributed() public view returns (uint256);
    function processInitialDistribution() onInitialDistribution onlyOwner public {
        initialDistribution();
        initialDistributionDone = true;
    }
    function initialTransfer(address to, uint256 amount) onInitialDistribution public {
        require(to != address(0));
        initiallyDistributed[to] = amount;
        token.transferFrom(msg.sender, to, amount);
    }
    function vest(address to, uint256 amount, uint256 releaseStart, uint256 cliff, uint256 duration) onInitialDistribution public {
        require(to != address(0));
        vested[to] = new TokenVesting(to, releaseStart, cliff, duration, false);
        token.transferFrom(msg.sender, vested[to], amount);
    }
    function lock(address to, uint256 amount, uint256 releaseTime) onInitialDistribution public {
        require(to != address(0));
        timelocked[to] = new TokenTimelock(token, to, releaseTime);
        token.transferFrom(msg.sender, address(timelocked[to]), amount);
    }
}
