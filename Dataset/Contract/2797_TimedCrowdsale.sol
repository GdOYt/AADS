contract TimedCrowdsale is Crowdsale {
  using SafeMath for uint256;
  uint256 public openingTime;
  uint256 public closingTime;
  modifier onlyWhileOpen {
    require(block.timestamp >= openingTime && block.timestamp <= closingTime);
    _;
  }
  constructor(uint256 _openingTime, uint256 _closingTime) public {
    openingTime = _openingTime;
    closingTime = _closingTime;
  }
  function hasClosed() public view returns (bool) {
    return block.timestamp > closingTime;
  }
  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal onlyWhileOpen {
    super._preValidatePurchase(_beneficiary, _weiAmount);
  }
}
