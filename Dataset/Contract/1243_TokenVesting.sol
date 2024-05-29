contract TokenVesting is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for ERC20;
  event Released(uint256 amount);
  event Revoked();
  address public beneficiary;
  uint256 public cliff;
  uint256 public start;
  uint256 public duration;
  bool public revocable;
  bool public revoked;
  uint256 public released;
  ERC20 public token;
  function TokenVesting(
    address _beneficiary,
    uint256 _start,
    uint256 _cliff,
    uint256 _duration,
    bool    _revocable,
    address _token
  ) {
    require(_beneficiary != 0x0);
    require(_cliff <= _duration);
    beneficiary = _beneficiary;
    start       = _start;
    cliff       = _start.add(_cliff);
    duration    = _duration;
    revocable   = _revocable;
    token       = ERC20(_token);
  }
  modifier onlyBeneficiary() {
    require(msg.sender == beneficiary);
    _;
  }
  function changeBeneficiary(address target) onlyBeneficiary public {
    require(target != 0);
    beneficiary = target;
  }
  function release() onlyBeneficiary public {
    require(now >= cliff);
    _releaseTo(beneficiary);
  }
  function releaseTo(address target) onlyBeneficiary public {
    require(now >= cliff);
    _releaseTo(target);
  }
  function _releaseTo(address target) internal {
    uint256 unreleased = releasableAmount();
    released = released.add(unreleased);
    token.safeTransfer(target, unreleased);
    Released(released);
  }
  function revoke() onlyOwner public {
    require(revocable);
    require(!revoked);
    _releaseTo(beneficiary);
    token.safeTransfer(owner, token.balanceOf(this));
    revoked = true;
    Revoked();
  }
  function releasableAmount() public constant returns (uint256) {
    return vestedAmount().sub(released);
  }
  function vestedAmount() public constant returns (uint256) {
    uint256 currentBalance = token.balanceOf(this);
    uint256 totalBalance = currentBalance.add(released);
    if (now < cliff) {
      return 0;
    } else if (now >= start.add(duration) || revoked) {
      return totalBalance;
    } else {
      return totalBalance.mul(now.sub(start)).div(duration);
    }
  }
  function releaseForeignToken(ERC20 _token, uint256 amount) onlyOwner {
    require(_token != token);
    _token.transfer(owner, amount);
  }
}
