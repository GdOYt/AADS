contract ERC918Interface {
  function totalSupply() public constant returns (uint);
  function getMiningDifficulty() public constant returns (uint);
  function getMiningTarget() public constant returns (uint);
  function getMiningReward() public constant returns (uint);
  function balanceOf(address tokenOwner) public constant returns (uint balance);
  function mint(uint256 nonce, bytes32 challenge_digest) public returns (bool success);
  event Mint(address indexed from, uint reward_amount, uint epochCount, bytes32 newChallengeNumber);
}
