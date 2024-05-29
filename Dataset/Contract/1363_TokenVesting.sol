contract TokenVesting is Ownable {
  using SafeMath for uint256;
  event Released(uint256 amount);
  address public beneficiary;
  TaylorToken public token;
  uint256 public cliff;
  uint256 public start;
  uint256 public duration;
  uint256 public released;
  function TokenVesting(address _beneficiary,address _token, uint256 _start, uint256 _cliff, uint256 _duration) public {
    require(_beneficiary != address(0));
    require(_cliff <= _duration);
    beneficiary = _beneficiary;
    duration = _duration;
    token = TaylorToken(_token);
    cliff = _start.add(_cliff);
    start = _start;
  }
  function release() public {
    uint256 unreleased = releasableAmount();
    require(unreleased > 0);
    released = released.add(unreleased);
    token.transfer(beneficiary, unreleased);
    Released(unreleased);
  }
  function releasableAmount() public view returns (uint256) {
    return vestedAmount().sub(released);
  }
  function vestedAmount() public view returns (uint256) {
    uint256 currentBalance = token.balanceOf(this);
    uint256 totalBalance = currentBalance.add(released);
    if (now < cliff) {
      return 0;
    } else if (now >= cliff && now < start.add(duration)) {
      return totalBalance / 2;
    } else {
      return totalBalance;
    }
  }
}
