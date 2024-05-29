contract TokenVesting is StandardToken,Ownable {
  using SafeMath for uint256;
  event AddToVestMap(address vestcount);
  event DelFromVestMap(address vestcount);
  event Released(address vestcount,uint256 amount);
  event Revoked(address vestcount);
  struct tokenToVest{
      bool  exist;
      uint256  start;
      uint256  cliff;
      uint256  duration;
      uint256  torelease;
      uint256  released;
  }
  mapping (address=>tokenToVest) vestToMap;
  function addToVestMap(
    address _beneficiary,
    uint256 _start,
    uint256 _cliff,
    uint256 _duration,
    uint256 _torelease
  ) public onlyOwner{
    require(_beneficiary != address(0));
    require(_cliff <= _duration);
    require(_start > block.timestamp);
    require(!vestToMap[_beneficiary].exist);
    vestToMap[_beneficiary] = tokenToVest(true,_start,_start.add(_cliff),_duration,
        _torelease,uint256(0));
    emit AddToVestMap(_beneficiary);
  }
  function delFromVestMap(
    address _beneficiary
  ) public onlyOwner{
    require(_beneficiary != address(0));
    require(vestToMap[_beneficiary].exist);
    delete vestToMap[_beneficiary];
    emit DelFromVestMap(_beneficiary);
  }
  function release(address _beneficiary) public {
    tokenToVest storage value = vestToMap[_beneficiary];
    require(value.exist);
    uint256 unreleased = releasableAmount(_beneficiary);
    require(unreleased > 0);
    require(unreleased + value.released <= value.torelease);
    vestToMap[_beneficiary].released = vestToMap[_beneficiary].released.add(unreleased);
    transfer(_beneficiary, unreleased);
    emit Released(_beneficiary,unreleased);
  }
  function releasableAmount(address _beneficiary) public view returns (uint256) {
    return vestedAmount(_beneficiary).sub(vestToMap[_beneficiary].released);
  }
  function vestedAmount(address _beneficiary) public view returns (uint256) {
    tokenToVest storage value = vestToMap[_beneficiary];
    uint256 totalBalance = value.torelease;
    if (block.timestamp < value.cliff) {
      return 0;
    } else if (block.timestamp >= value.start.add(value.duration)) {
      return totalBalance;
    } else {
      return totalBalance.mul(block.timestamp.sub(value.start)).div(value.duration);
    }
  }
}
