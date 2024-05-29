contract Crowdsale is Ownable, ReentrancyGuard, Stateful {
  using SafeMath for uint;
  mapping (address => uint) preICOinvestors;
  mapping (address => uint) ICOinvestors;
  BSEToken public token ;
  uint256 public startICO;
  uint256 public startPreICO;
  uint256 public period;
  uint256 public constant rateCent = 2000000000000000;
  uint256 public constant preICOTokenHardCap = 440000 * 1 ether;
  uint256 public constant ICOTokenHardCap = 1540000 * 1 ether;
  uint256 public collectedCent;
  uint256 day = 86400;  
  uint256 public soldTokens;
  uint256 public priceUSD;  
  address multisig;
  address public oracle;
  modifier onlyOwnerOrOracle() {
    require(msg.sender == oracle || msg.sender == owner);
    _;
  }
  function changeOracle(address _oracle) onlyOwner external {
    require(_oracle != 0);
    oracle = _oracle;
  }
  modifier saleIsOn() {
    require((state == State.PreIco || state == State.ICO) &&(now < startICO + period || now < startPreICO + period));
    _;
  }
  modifier isUnderHardCap() {
    require(soldTokens < getHardcap());
    _;
  }
  function getHardcap() internal returns(uint256) {
    if (state == State.PreIco) {
      return preICOTokenHardCap;
    }
    else {
      if (state == State.ICO) {
        return ICOTokenHardCap;
      }
    }
  }
  function Crowdsale(address _multisig, uint256 _priceUSD) {
    priceUSD = _priceUSD;
    multisig = _multisig;
    token = new BSEToken();
  }
  function startCompanySell() onlyOwner {
    require(state== State.CrowdsaleFinished);
    setState(State.companySold);
  }
  function usdSale(address _to, uint _valueUSD) onlyOwner  {
    uint256 valueCent = _valueUSD * 100;
    uint256 tokensAmount = rateCent.mul(valueCent);
    collectedCent += valueCent;
    token.mint(_to, tokensAmount);
    if (state == State.ICO || state == State.preIcoFinished) {
      ICOinvestors[_to] += tokensAmount;
    } else {
      preICOinvestors[_to] += tokensAmount;
    }
    soldTokens += tokensAmount;
  }
  function pauseSale() onlyOwner {
    require(state == State.ICO);
    setState(State.salePaused);
  }
  function pausePreSale() onlyOwner {
    require(state == State.PreIco);
    setState(State.PreIcoPaused);
  }
  function startPreIco(uint256 _period, uint256 _priceUSD) onlyOwner {
    require(_period > 0);
    require(state == State.Init || state == State.PreIcoPaused);
    priceUSD = _priceUSD;
    startPreICO = now;
    period = _period * day;
    setState(State.PreIco);
  }
  function finishPreIco() onlyOwner {
    require(state == State.PreIco);
    setState(State.preIcoFinished);
    bool isSent = multisig.call.gas(3000000).value(this.balance)();
    require(isSent);
  }
  function startIco(uint256 _period, uint256 _priceUSD) onlyOwner {
    require(_period > 0);
    require(state == State.PreIco || state == State.salePaused || state == State.preIcoFinished);
    priceUSD = _priceUSD;
    startICO = now;
    period = _period * day;
    setState(State.ICO);
  }
  function setPriceUSD(uint256 _priceUSD) onlyOwnerOrOracle {
    priceUSD = _priceUSD;
  }
  function finishICO() onlyOwner {
    require(state == State.ICO);
    setState(State.CrowdsaleFinished);
    bool isSent = multisig.call.gas(3000000).value(this.balance)();
    require(isSent);
  }
  function finishMinting() onlyOwner {
    token.finishMinting();
  }
  function getDouble() nonReentrant {
    require (state == State.ICO || state == State.companySold);
    uint256 extraTokensAmount;
    if (state == State.ICO) {
      extraTokensAmount = preICOinvestors[msg.sender];
      preICOinvestors[msg.sender] = 0;
      token.mint(msg.sender, extraTokensAmount);
      ICOinvestors[msg.sender] += extraTokensAmount;
    }
    else {
      if (state == State.companySold) {
        extraTokensAmount = preICOinvestors[msg.sender] + ICOinvestors[msg.sender];
        preICOinvestors[msg.sender] = 0;
        ICOinvestors[msg.sender] = 0;
        token.mint(msg.sender, extraTokensAmount);
      }
    }
  }
  function mintTokens() payable saleIsOn isUnderHardCap nonReentrant {
    uint256 valueWEI = msg.value;
    uint256 valueCent = valueWEI.div(priceUSD);
    uint256 tokens = rateCent.mul(valueCent);
    uint256 hardcap = getHardcap();
    if (soldTokens + tokens > hardcap) {
      tokens = hardcap.sub(soldTokens);
      valueCent = tokens.div(rateCent);
      valueWEI = valueCent.mul(priceUSD);
      uint256 change = msg.value - valueWEI;
      bool isSent = msg.sender.call.gas(3000000).value(change)();
      require(isSent);
    }
    token.mint(msg.sender, tokens);
    collectedCent += valueCent;
    soldTokens += tokens;
    if (state == State.PreIco) {
      preICOinvestors[msg.sender] += tokens;
    }
    else {
      ICOinvestors[msg.sender] += tokens;
    }
  }
  function () payable {
    mintTokens();
  }
}
