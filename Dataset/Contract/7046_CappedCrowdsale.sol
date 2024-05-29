contract CappedCrowdsale is Crowdsale, Ownable {
  using SafeMath for uint256;
  uint256 public hardCap;
  bool public isFinalized = false;
  uint256 public vestingTokens;
  uint256 public vestingDuration;
  uint256 public vestingPeriod;
  address public vestingBeneficiary;
  GambioVesting public vesting;
  event Finalized();
  event FinishMinting();
  event TokensMinted(
    address indexed beneficiary,
    uint256 indexed amount
  );
  constructor(uint256 _hardCap, uint256[] _vestingData, address _beneficiary)
  public {
    require(_vestingData.length == 3);
    require(_hardCap > 0);
    require(_vestingData[0] > 0);
    require(_vestingData[1] > 0);
    require(_vestingData[2] > 0);
    require(_beneficiary != address(0));
    hardCap = _hardCap;
    vestingTokens = _vestingData[0];
    vestingDuration = _vestingData[1];
    vestingPeriod = _vestingData[2];
    vestingBeneficiary = _beneficiary;
  }
  function finalize() public onlyOwner {
    require(!isFinalized);
    vesting = new GambioVesting(vestingPeriod, vestingBeneficiary, now, 0, vestingDuration, false);
    token.mint(address(vesting), vestingTokens);
    emit Finalized();
    isFinalized = true;
  }
  function finishMinting() public onlyOwner {
    require(token.mintingFinished() == false);
    require(isFinalized);
    token.finishMinting();
    emit FinishMinting();
  }
  function mint(address beneficiary, uint256 amount) public onlyOwner {
    require(!token.mintingFinished());
    require(isFinalized);
    require(amount > 0);
    require(beneficiary != address(0));
    token.mint(beneficiary, amount);
    emit TokensMinted(beneficiary, amount);
  }
  function hasEnded() public view returns (bool) {
    bool capReached = weiRaised >= hardCap;
    return super.hasEnded() || capReached || isFinalized;
  }
}
