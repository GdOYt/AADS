contract Crowdsale is Ownable, usingOraclize{
  using SafeMath for uint;
  uint public decimals = 18;
  address public distributionAddress;
  uint public startingExchangePrice = 1902877214779731;
  ArtNoyToken public token;
  constructor (address _tokenAddress, address _distributionAddress) public payable{
    require (msg.value > 0);
    token = ArtNoyToken(_tokenAddress);
    techSupport = 0x08531Ea431B6adAa46D2e7a75f48A8d9Ce412FDc;
    token.setCrowdsaleContract(this);
    owner = token.getOwner();
    distributionAddress = _distributionAddress;
    oraclize_setNetwork(networkID_auto);
    oraclize = OraclizeI(OAR.getAddress());
    oraclizeBalance = msg.value;
    tokenPrice = startingExchangePrice;
    oraclize_query("URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHUSD).result.XETHZUSD.c.0");
  }
  uint public ethCollected;
  uint public tokensSold;
  uint public minDeposit = 0.01 ether;
  uint public tokenPrice;  
  uint public constant PRE_ICO_START = 1528243201;  
  uint public constant PRE_ICO_FINISH = 1530403199;  
  uint public constant PRE_ICO_MIN_CAP = 0;
  uint public constant PRE_ICO_MAX_CAP = 5000000 ether;  
  uint public preIcoTokensSold;
  uint public constant ICO_START = 1530403201;  
  uint public constant ICO_FINISH = 1544918399;  
  uint public constant ICO_MIN_CAP = 10000 ether;  
  uint public constant ICO_MAX_CAP = 55000000 ether;  
  mapping (address => uint) contributorsBalances;
  function getCurrentPhase (uint _time) public view returns(uint8){
    if(_time == 0){
      _time = now;
    }
    if (PRE_ICO_START < _time && _time <= PRE_ICO_FINISH){
      return 1;
    }
    if (ICO_START < _time && _time <= ICO_FINISH){
      return 2;
    }
    return 0;
  }
  function getTimeBasedBonus (uint _time) public view returns(uint) {
    if(_time == 0){
      _time = now;
    }
    uint8 phase = getCurrentPhase(_time);
    if(phase == 1){
      return 20;
    }
    if(phase == 2){
      if (ICO_START + 90 days <= _time){
        return 20;
      }
      if (ICO_START + 180 days <= _time){
        return 10;
      }
      if (ICO_START + 365 days <= _time){  
        return 5;
      }
    }
    return 0;
  }
  event OnSuccessfullyBuy(address indexed _address, uint indexed _etherValue, bool indexed isBought, uint _tokenValue);
  function () public payable {
    require (msg.value >= minDeposit);
    require (buy(msg.sender, msg.value, now));
  }
  function buy (address _address, uint _value, uint _time) internal returns(bool){
    uint8 currentPhase = getCurrentPhase(_time);
    require (currentPhase != 0);
    uint tokensToSend = calculateTokensWithBonus(_value);
    ethCollected = ethCollected.add(_value);
    tokensSold = tokensSold.add(tokensToSend);
    if (currentPhase == 1){
      require (preIcoTokensSold.add(tokensToSend) <= PRE_ICO_MAX_CAP);
      preIcoTokensSold = preIcoTokensSold.add(tokensToSend);
      distributionAddress.transfer(address(this).balance.sub(oraclizeBalance));
    }else{
      contributorsBalances[_address] = contributorsBalances[_address].add(_value);
      if(tokensSold >= ICO_MIN_CAP){
        if(!areTokensSended){
          token.icoSucceed();
          areTokensSended = true;
        }
        distributionAddress.transfer(address(this).balance.sub(oraclizeBalance));
      }
    }
    emit OnSuccessfullyBuy(_address,_value,true, tokensToSend);
    token.sendCrowdsaleTokens(_address, tokensToSend);
    return true;
  }
  bool public areTokensSended = false; 
  function calculateTokensWithoutBonus (uint _value) public view returns(uint) {
    return _value.mul(uint(10).pow(decimals))/(tokenPrice);
  }
  function calculateTokensWithBonus (uint _value) public view returns(uint) {
    uint buffer = _value.mul(uint(10).pow(decimals))/(tokenPrice);
    return buffer.add(buffer.mul(getTimeBasedBonus(now))/100);
  }
  function isIcoTrue () public view returns(bool) {
    if (tokensSold >= ICO_MIN_CAP){
      return true;
    }
    return false;
  }
  function refund () public {
    require (now > ICO_FINISH && !isIcoTrue());
    require (contributorsBalances[msg.sender] != 0);
    uint balance = contributorsBalances[msg.sender];
    contributorsBalances[msg.sender] = 0;
    msg.sender.transfer(balance);
  }
  function manualSendEther (address _address, uint _value) public onlyTechSupport {
    uint tokensToSend = calculateTokensWithBonus(_value);
    ethCollected = ethCollected.add(_value);
    tokensSold = tokensSold.add(tokensToSend);
    token.sendCrowdsaleTokens(_address, tokensToSend);
    emit OnSuccessfullyBuy(_address, 0, false, tokensToSend);
  }
  function manualSendTokens (address _address, uint _value) public onlyTechSupport {
    tokensSold = tokensSold.add(_value);
    token.sendCrowdsaleTokens(_address, _value);
    emit OnSuccessfullyBuy(_address, 0, false, _value);
  }
  event IcoEnded();
  function endIco () public onlyOwner {
    require (now > ICO_FINISH);
    token.endIco();
    emit IcoEnded();
  }
  uint public oraclizeBalance;
  bool public updateFlag = true;
  uint public priceUpdateAt;
  function update() internal {
    oraclize_query(86400,"URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHUSD).result.XETHZUSD.c.0");
    oraclizeBalance = oraclizeBalance.sub(oraclize_getPrice("URL"));  
  }
  function startOraclize (uint _time) public onlyOwner {
    require (_time != 0);
    require (!updateFlag);
    updateFlag = true;
    oraclize_query(_time,"URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHUSD).result.XETHZUSD.c.0");
    oraclizeBalance = oraclizeBalance.sub(oraclize_getPrice("URL"));
  }
  function addEtherForOraclize () public payable {
    oraclizeBalance = oraclizeBalance.add(msg.value);
  }
  function requestOraclizeBalance () public onlyOwner {
    updateFlag = false;
    if (address(this).balance >= oraclizeBalance){
      owner.transfer(oraclizeBalance);
    }else{
      owner.transfer(address(this).balance);
    }
    oraclizeBalance = 0;
  }
  function stopOraclize () public onlyOwner {
    updateFlag = false;
  }
  function __callback(bytes32, string result, bytes) public {
    require(msg.sender == oraclize_cbAddress());
    uint256 price = 10 ** 23 / parseInt(result, 5);
    require(price > 0);
    tokenPrice = price;
    priceUpdateAt = block.timestamp;
    if(updateFlag){
      update();
    }
  }
}
