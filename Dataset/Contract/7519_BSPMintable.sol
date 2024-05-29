contract BSPMintable is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for ERC20Basic;
  event Mint(uint256 amount);
  event DistributorChanged(address indexed previousDistributor, address indexed newDistributor);
  address public distributor = 0x4F91C1f068E0dED2B7fF823289Add800E1c26Fc3;
  ERC20Basic public BSPToken = ERC20Basic(0x5d551fA77ec2C7dd1387B626c4f33235c3885199);
  uint256 constant public rewardAmount = 630000000 * (10 ** 18);
  uint256 constant public duration = 4 years;
  uint256[4] public miningRate = [40,20,20,20];
  bool public started = false;
  uint256 public startTime;
  uint256 public minted;
  modifier whenStarted() {
    require(started == true && startTime <= block.timestamp);
    _;
  }
  function startMining(uint256 _startTime) public onlyOwner {
      require(started == false && BSPToken.balanceOf(this) >= rewardAmount);
      require(_startTime >= block.timestamp);
      require(_startTime <= block.timestamp + 60 days);
      startTime = _startTime;
      started = true;
  }
  function changeDistributor(address _newDistributor) public onlyOwner {
    emit DistributorChanged(distributor, _newDistributor);
    distributor = _newDistributor;
  }
  function mint() public whenStarted {
    uint256 unminted = mintableAmount();
    require(unminted > 0);
    minted = minted.add(unminted);
    BSPToken.safeTransfer(distributor, unminted);
    emit Mint(unminted);
  }
  function mintableAmount() public view returns (uint256) {
    if(started == false || startTime >= block.timestamp){
        return 0;
    }
    if (block.timestamp >= startTime.add(duration)){
        return BSPToken.balanceOf(this);
    }
    uint currentYear = block.timestamp.sub(startTime).div(1 years);
    uint currentDay = (block.timestamp.sub(startTime) % (1 years)).div(1 days);
    uint currentMintable = 0;
    for (uint i = 0; i < currentYear; i++){
        currentMintable = currentMintable.add(rewardAmount.mul(miningRate[i]).div(100));
    }
    currentMintable = currentMintable.add(rewardAmount.mul(miningRate[currentYear]).div(36500).mul(currentDay));
    return currentMintable.sub(minted);
  }
  function totalBspAmount() public view returns (uint256) {
      return BSPToken.balanceOf(this).add(minted);
  }
  function () public payable {
    revert ();
  }
}
