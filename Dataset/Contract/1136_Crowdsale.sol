contract Crowdsale is Ownable {
  using SafeMath for uint256;
  BVA public token;
  uint256 public startPreICO;
  uint256 public endPreICO;  
  uint256 public startICO;
  uint256 public endICO;
  uint256 public sumHardCapPreICO;
  uint256 public sumHardCapICO;
  uint256 public sumPreICO;
  uint256 public sumICO;
  uint256 public minInvestmentPreICO;
  uint256 public minInvestmentICO;
  uint256 public maxInvestmentICO;
  uint256 public ratePreICO; 
  uint256 public rateICO;
  address public wallet;
  uint256 public maxRefererTokens;
  uint256 public allRefererTokens;
  event TokenProcurement(address indexed contributor, address indexed beneficiary, uint256 value, uint256 amount);
  function Crowdsale() public {
    token = createTokenContract();
    sumHardCapPreICO = 15000000 * 1 ether;
    sumHardCapICO = 1000000 * 1 ether;
    maxRefererTokens = 2500000 * 1 ether;
    minInvestmentPreICO = 3 * 1 ether;
    minInvestmentICO = 100000000000000000;  
    maxInvestmentICO = 5 * 1 ether;
    ratePreICO = 1500;
    rateICO = 1000;    
    wallet = 0x00a134aE23247c091Dd4A4dC1786358f26714ea3;
  }
  function setRatePreICO(uint256 _ratePreICO) public onlyOwner  {
    ratePreICO = _ratePreICO;
  } 
  function setRateICO(uint256 _rateICO) public onlyOwner  {
    rateICO = _rateICO;
  }  
  function setStartPreICO(uint256 _startPreICO) public onlyOwner  {
    startPreICO = _startPreICO;
  }   
  function setEndPreICO(uint256 _endPreICO) public onlyOwner  {
    endPreICO = _endPreICO;
  }
  function setStartICO(uint256 _startICO) public onlyOwner  {
    startICO = _startICO;
  }
  function setEndICO(uint256 _endICO) public onlyOwner  {
    endICO = _endICO;
  }
  function () external payable {
    procureTokens(msg.sender);
  }
  function createTokenContract() internal returns (BVA) {
    return new BVA();
  }
  function adjustHardCap(uint256 _value) internal {
    if (now >= startPreICO && now < endPreICO){
      sumPreICO = sumPreICO.add(_value);
    }  
    if (now >= startICO && now < endICO){
      sumICO = sumICO.add(_value);
    }       
  }  
  function checkHardCap(uint256 _value) view public {
    if (now >= startPreICO && now < endPreICO){
      require(_value.add(sumPreICO) <= sumHardCapPreICO);
    }  
    if (now >= startICO && now < endICO){
      require(_value.add(sumICO) <= sumHardCapICO);
    }       
  } 
  function checkMinMaxInvestment(uint256 _value) view public {
    if (now >= startPreICO && now < endPreICO){
      require(_value >= minInvestmentPreICO);
    }  
    if (now >= startICO && now < endICO){
      require(_value >= minInvestmentICO);
      require(_value <= maxInvestmentICO);
    }       
  }
  function bytesToAddress(bytes source) internal pure returns(address) {
    uint result;
    uint mul = 1;
    for(uint i = 20; i > 0; i--) {
      result += uint8(source[i-1])*mul;
      mul = mul*256;
    }
    return address(result);
  }
  function procureTokens(address _beneficiary) public payable {
    uint256 tokens;
    uint256 weiAmount = msg.value;
    address _this = this;
    uint256 rate;
    address referer;
    uint256 refererTokens;
    require(now >= startPreICO);
    require(now <= endICO);
    require(_beneficiary != address(0));
    checkMinMaxInvestment(weiAmount);
    rate = getRate();
    tokens = weiAmount.mul(rate);
	if(msg.data.length == 20) {
      referer = bytesToAddress(bytes(msg.data));
      require(referer != msg.sender);
      refererTokens = tokens.mul(5).div(100);
    }
    checkHardCap(tokens.add(refererTokens));
    adjustHardCap(tokens.add(refererTokens));
    wallet.transfer(_this.balance);
	if (refererTokens != 0 && allRefererTokens.add(refererTokens) <= maxRefererTokens){
	  allRefererTokens = allRefererTokens.add(refererTokens);
      token.mint(referer, refererTokens);	  
	}    
    token.mint(_beneficiary, tokens);
    emit TokenProcurement(msg.sender, _beneficiary, weiAmount, tokens);
  }
  function getRate() public view returns (uint256) {
    uint256 rate;
    if (now >= startPreICO && now < endPreICO){
      rate = ratePreICO;
    }  
    if (now >= startICO && now < endICO){
      rate = rateICO;
    }      
    return rate;
  }  
}
