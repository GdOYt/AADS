contract ZeroGoldPOWMining is Owned {
    using SafeMath for uint;
    ERC20Interface zeroGold;
    ERC918Interface public miningLeader;
    address public mintHelper = 0x0;
    modifier onlyMintHelper {
        require(msg.sender == mintHelper);
        _;
    }
    uint rewardDivisor = 20;
    uint epochCount = 0;
    uint public lastRewardAmount = 0;
    mapping(bytes32 => bytes32) solutionForChallenge;
    event Mint(address indexed from, uint reward_amount, uint epochCount, bytes32 newChallengeNumber);
    constructor(address _miningLeader, address _mintHelper) public  {
        miningLeader = ERC918Interface(_miningLeader);
        mintHelper = _mintHelper;
        zeroGold = ERC20Interface(0x6ef5bca539A4A01157af842B4823F54F9f7E9968);
    }
    function merge() external onlyMintHelper returns (bool success) {
        bytes32 futureChallengeNumber = blockhash(block.number - 1);
        bytes32 challengeNumber = miningLeader.getChallengeNumber();
        if (challengeNumber == futureChallengeNumber) {
            return false; 
        }
        if (miningLeader.lastRewardTo() != msg.sender) {
            return false;
        }
        if (miningLeader.lastRewardEthBlockNumber() != block.number) {
            return false;
        }
        bytes32 parentChallengeNumber = miningLeader.challengeNumber();
        bytes32 solution = solutionForChallenge[parentChallengeNumber];
        if (solution != 0x0) return false;  
        bytes32 digest = 'merge';
        solutionForChallenge[parentChallengeNumber] = digest;
        uint rewardAmount = getRewardAmount();
        uint balance = zeroGold.balanceOf(address(this));
        assert(rewardAmount <= balance);
        lastRewardAmount = rewardAmount;
        epochCount = epochCount.add(1);
        emit Mint(msg.sender, rewardAmount, epochCount, 0);
        return true;
    }
    function transfer(
        address _wallet, 
        uint _reward
    ) external onlyMintHelper returns (bool) {
        if (_reward > lastRewardAmount) {
            return false;
        }
        lastRewardAmount = lastRewardAmount.sub(_reward);
        zeroGold.transfer(_wallet, _reward);
    }
    function getRewardAmount() public constant returns (uint) {
        uint totalBalance = zeroGold.balanceOf(address(this));
        return totalBalance.div(rewardDivisor);
    }
    function setMiningLeader(address _miningLeader) external onlyOwner {
        miningLeader = ERC918Interface(_miningLeader);
    }
    function setMintHelper(address _mintHelper) external onlyOwner {
        mintHelper = _mintHelper;
    }
    function setRewardDivisor(uint _rewardDivisor) external onlyOwner {
        rewardDivisor = _rewardDivisor;
    }
    function () public payable {
        revert('Oops! Direct payments are NOT permitted here.');
    }
    function transferAnyERC20Token(
        address tokenAddress, uint tokens
    ) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}
