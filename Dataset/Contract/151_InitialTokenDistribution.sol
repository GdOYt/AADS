contract InitialTokenDistribution is Ownable {
    using SafeMath for uint256;
    ERC20 public token;
    mapping (address => TokenTimelock) public timelocked;
    mapping (address => uint256) public initiallyDistributed;
    bool public initialDistributionDone = false;
    modifier onInitialDistribution() {
        require(!initialDistributionDone);
        _;
    }
    function InitialTokenDistribution(
        ERC20 _token
    ) public {
        token = _token;
    }
    function initialDistribution() internal;
    function totalTokensDistributed() view public returns (uint256);
    function processInitialDistribution() onInitialDistribution public onlyOwner {
        initialDistribution();
        initialDistributionDone = true;
    }
    function initialTransfer(address to, uint256 amount) public onInitialDistribution {
        require(to != address(0));
        initiallyDistributed[to] = amount;
        token.transferFrom(msg.sender, to, amount);
    }
    function lock(address to, uint256 amount, uint256 releaseTime) public onInitialDistribution {
        require(to != address(0));
        timelocked[to] = new TokenTimelock(token, to, releaseTime);
        token.transferFrom(msg.sender, address(timelocked[to]), amount);
    }
}
