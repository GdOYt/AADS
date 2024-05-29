contract PTG_Crowdsale is Pausable {
  using SafeMath for uint256;
  ERC20 public token;
  address public wallet;
  uint256 public supply;
  uint256 public rate;
  uint256 public weiRaised;
  uint256 public openingTime;
  uint256 public closingTime;
  uint256 public duration;
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
  constructor() public {
    rate = 10;
    wallet = owner;
    token = ERC20(0x88cDF00f95d31904600b2cd8110b95ac970E0E2F);
    duration = 60 days;
    openingTime = 1534291200;   
    closingTime = openingTime + duration;   
  }
  function start() public onlyOwner {
    openingTime = now;       
    closingTime =  now + duration;
  }
  function getCurrentRate() public view returns (uint256) {
    if (now <= openingTime.add(14 days)) return rate.add(rate/5);    
    if (now > openingTime.add(14 days) && now <= openingTime.add(28 days)) return rate.add(rate*3/20);    
    if (now > openingTime.add(28 days) && now <= openingTime.add(42 days)) return rate.add(rate/10);    
  }
  function () external payable {
    buyTokens(msg.sender);
  }
  function buyTokens(address _beneficiary) public payable {
    uint256 weiAmount = msg.value;
    _preValidatePurchase(_beneficiary, weiAmount);
    uint256 tokens = _getTokenAmount(weiAmount);
    weiRaised = weiRaised.add(weiAmount);
    _processPurchase(_beneficiary, tokens);
    emit TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens);
    _forwardFunds();
  }
  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal whenNotPaused {
    require(_beneficiary != address(0));
    require(_weiAmount != 0);
    require(now >= openingTime && now <= closingTime);
  }
  function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
    token.transfer(_beneficiary, _tokenAmount);
  }
  function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
    _deliverTokens(_beneficiary, _tokenAmount);
  }
  function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
    uint256 currentRate = getCurrentRate();
    return currentRate.mul(_weiAmount);
  }
  function _forwardFunds() internal {
    wallet.transfer(msg.value);
  }
  function hasClosed() public view returns (bool) {
    return now > closingTime;
  }
  function withdrawTokens() public onlyOwner {
    uint256 unsold = token.balanceOf(this);
    token.transfer(owner, unsold);
  }
}
