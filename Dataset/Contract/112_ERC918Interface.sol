contract ERC918Interface {
    function getChallengeNumber() public constant returns (bytes32);
    function getMiningDifficulty() public constant returns (uint);
    function getMiningTarget() public constant returns (uint);
    function getMiningReward() public constant returns (uint);
    function mint(uint256 nonce, bytes32 challenge_digest) public returns (bool success);
    event Mint(address indexed from, uint reward_amount, uint epochCount, bytes32 newChallengeNumber);
    address public lastRewardTo;
    uint public lastRewardAmount;
    uint public lastRewardEthBlockNumber;
    bytes32 public challengeNumber;
}
