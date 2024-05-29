contract TokenTimelock {
  using SafeERC20 for ERC20Basic;
  ERC20Basic public token;
  address public beneficiary;
  uint256 public releaseTime;
  function TokenTimelock(ERC20Basic _token, address _beneficiary, uint256 _releaseTime) public {
    require(_releaseTime > now);
    token = _token;
    beneficiary = _beneficiary;
    releaseTime = _releaseTime;
  }
  function release() public {
    require(now >= releaseTime);
    uint256 amount = token.balanceOf(this);
    require(amount > 0);
    token.safeTransfer(beneficiary, amount);
  }
}
