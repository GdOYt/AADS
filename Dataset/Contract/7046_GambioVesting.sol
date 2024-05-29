contract GambioVesting is TokenVesting {
  using SafeMath for uint256;
  uint256 public previousRelease;
  uint256 period;
  constructor(uint256 _period, address _beneficiary, uint256 _start, uint256 _cliff, uint256 _duration, bool _revocable)
  public
  TokenVesting(_beneficiary, _start, _cliff, _duration, _revocable) {
    period = _period;
    previousRelease = now;
  }
  function release(ERC20Basic token) public {
    require(now >= previousRelease.add(period));
    uint256 unreleased = releasableAmount(token);
    require(unreleased > 0);
    released[token] = released[token].add(unreleased);
    token.safeTransfer(beneficiary, unreleased);
    previousRelease = now;
    emit Released(unreleased);
  }
}
