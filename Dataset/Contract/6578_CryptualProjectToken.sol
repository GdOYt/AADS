contract CryptualProjectToken is StandardToken, Ownable {
  using SafeMath for uint256;
  string public constant name = "Cryptual Project Token";  
  string public constant symbol = "CPT";  
  uint8 public constant decimals = 0;  
  uint256 public constant INITIAL_SUPPLY = 283000000;
  address public wallet;
  uint256 public constant PRESALE_OPENING_TIME = 1531998000;  
  uint256 public constant PRESALE_CLOSING_TIME = 1532563200;  
  uint256 public constant PRESALE_RATE = 150000;
  uint256 public constant PRESALE_WEI_CAP = 500 ether;
  uint256 public constant PRESALE_WEI_GOAL = 50 ether;
  uint256 public constant CROWDSALE_OPENING_TIME = 1532602800;  
  uint256 public constant CROWDSALE_CLOSING_TIME = 1535328000;  
  uint256 public constant CROWDSALE_WEI_CAP = 5000 ether;
  uint256 public constant COMBINED_WEI_GOAL = 750 ether;
  uint256[] public crowdsaleWeiAvailableLevels = [1000 ether, 1500 ether, 2000 ether];
  uint256[] public crowdsaleRates = [135000, 120000, 100000];
  uint256[] public crowdsaleMinElapsedTimeLevels = [0, 12 * 3600, 18 * 3600, 21 * 3600, 22 * 3600];
  uint256[] public crowdsaleUserCaps = [1 ether, 2 ether, 4 ether, 8 ether, CROWDSALE_WEI_CAP];
  mapping(address => uint256) public crowdsaleContributions;
  uint256 public presaleWeiRaised;
  uint256 public crowdsaleWeiRaised;
  constructor(
    address _wallet
  ) public {
    require(_wallet != address(0));
    wallet = _wallet;
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);
  }
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
  function () external payable {
    buyTokens(msg.sender);
  }
  function buyTokens(address _beneficiary) public payable {
    uint256 weiAmount = msg.value;
    require(_beneficiary != address(0));
    require(weiAmount != 0);
    bool isPresale = block.timestamp >= PRESALE_OPENING_TIME && block.timestamp <= PRESALE_CLOSING_TIME;
    bool isCrowdsale = block.timestamp >= CROWDSALE_OPENING_TIME && block.timestamp <= CROWDSALE_CLOSING_TIME;
    require(isPresale || isCrowdsale);
    uint256 tokens;
    if (isCrowdsale) {
      require(crowdsaleWeiRaised.add(weiAmount) <= CROWDSALE_WEI_CAP);
      require(crowdsaleContributions[_beneficiary].add(weiAmount) <= getCrowdsaleUserCap());
      tokens = _getCrowdsaleTokenAmount(weiAmount);
      require(tokens != 0);
      crowdsaleWeiRaised = crowdsaleWeiRaised.add(weiAmount);
    } else if (isPresale) {
      require(presaleWeiRaised.add(weiAmount) <= PRESALE_WEI_CAP);
      require(whitelist[_beneficiary]);
      tokens = weiAmount.mul(PRESALE_RATE).div(1 ether);
      require(tokens != 0);
      presaleWeiRaised = presaleWeiRaised.add(weiAmount);
    }
    _processPurchase(_beneficiary, tokens);
    emit TokenPurchase(
      msg.sender,
      _beneficiary,
      weiAmount,
      tokens
    );
    if (isCrowdsale) crowdsaleContributions[_beneficiary] = crowdsaleContributions[_beneficiary].add(weiAmount);
    deposited[_beneficiary] = deposited[_beneficiary].add(msg.value);
  }
  function getCrowdsaleUserCap() public view returns (uint256) {
    require(block.timestamp >= CROWDSALE_OPENING_TIME && block.timestamp <= CROWDSALE_CLOSING_TIME);
    uint256 elapsedTime = block.timestamp.sub(CROWDSALE_OPENING_TIME);
    uint256 currentMinElapsedTime = 0;
    uint256 currentCap = 0;
    for (uint i = 0; i < crowdsaleUserCaps.length; i++) {
      if (elapsedTime < crowdsaleMinElapsedTimeLevels[i]) continue;
      if (crowdsaleMinElapsedTimeLevels[i] < currentMinElapsedTime) continue;
      currentCap = crowdsaleUserCaps[i];
    }
    return currentCap;
  }
  function _getCrowdsaleTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
    uint256 uncountedWeiRaised = crowdsaleWeiRaised;
    uint256 uncountedWeiAmount = _weiAmount;
    uint256 tokenAmount = 0;
    for (uint i = 0; i < crowdsaleWeiAvailableLevels.length; i++) {
      uint256 weiAvailable = crowdsaleWeiAvailableLevels[i];
      uint256 rate = crowdsaleRates[i];
      if (uncountedWeiRaised < weiAvailable) {
        if (uncountedWeiRaised > 0) {
          weiAvailable = weiAvailable.sub(uncountedWeiRaised);
          uncountedWeiRaised = 0;
        }
        if (uncountedWeiAmount <= weiAvailable) {
          tokenAmount = tokenAmount.add(uncountedWeiAmount.mul(rate));
          break;
        } else {
          uncountedWeiAmount = uncountedWeiAmount.sub(weiAvailable);
          tokenAmount = tokenAmount.add(weiAvailable.mul(rate));
        }
      } else {
        uncountedWeiRaised = uncountedWeiRaised.sub(weiAvailable);
      }
    }
    return tokenAmount.div(1 ether);
  }
  function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
    totalSupply_ = totalSupply_.add(_tokenAmount);
    balances[_beneficiary] = balances[_beneficiary].add(_tokenAmount);
    emit Transfer(0x0, _beneficiary, _tokenAmount);
  }
  mapping(address => bool) public whitelist;
  function addToPresaleWhitelist(address _beneficiary) external onlyOwner {
    whitelist[_beneficiary] = true;
  }
  function addManyToPresaleWhitelist(address[] _beneficiaries) external onlyOwner {
    for (uint256 i = 0; i < _beneficiaries.length; i++) {
      whitelist[_beneficiaries[i]] = true;
    }
  }
  function removeFromPresaleWhitelist(address _beneficiary) external onlyOwner {
    whitelist[_beneficiary] = false;
  }
  bool public isCrowdsaleFinalized = false;
  mapping (address => uint256) public deposited;
  event CrowdsaleFinalized();
  event RefundsEnabled();
  event Refunded(address indexed beneficiary, uint256 weiAmount);
  function finalizeCrowdsale() external {
    require(!isCrowdsaleFinalized);
    require(block.timestamp > CROWDSALE_CLOSING_TIME || (block.timestamp > PRESALE_CLOSING_TIME && presaleWeiRaised < PRESALE_WEI_GOAL));
    if (combinedGoalReached()) {
      wallet.transfer(address(this).balance);
    } else {
      emit RefundsEnabled();
    }
    emit CrowdsaleFinalized();
    isCrowdsaleFinalized = true;
  }
  function claimRefund() external {
    require(isCrowdsaleFinalized);
    require(!combinedGoalReached());
    require(deposited[msg.sender] > 0);
    uint256 depositedValue = deposited[msg.sender];
    deposited[msg.sender] = 0;
    msg.sender.transfer(depositedValue);
    emit Refunded(msg.sender, depositedValue);
  }
  function combinedGoalReached() public view returns (bool) {
    return presaleWeiRaised.add(crowdsaleWeiRaised) >= COMBINED_WEI_GOAL;
  }
}
