contract GeneNuggetsToken is Pausable,StandardToken {
  using SafeMath for uint256;
  string public name = "Gene Nuggets";
  string public symbol = "GNUS";
  uint8 public decimals = 6;
  uint256 public decimalFactor = 10 ** uint256(decimals);
  uint public CAP = 30e8 * decimalFactor;  
  uint256 public circulatingSupply;
  uint256 public totalUsers;
  uint256 public exchangeLimit = 10000*decimalFactor;
  uint256 public exchangeThreshold = 2000*decimalFactor;
  uint256 public exchangeInterval = 60;
  uint256 public destroyThreshold = 100*decimalFactor;
  address public CFO;  
  mapping(address => uint256) public CustomerService;  
  uint[10] public MINING_LAYERS = [0,10e4,30e4,100e4,300e4,600e4,1000e4,2000e4,3000e4,2**256 - 1];
  uint[9] public MINING_REWARDS = [1000*decimalFactor,600*decimalFactor,300*decimalFactor,200*decimalFactor,180*decimalFactor,160*decimalFactor,60*decimalFactor,39*decimalFactor,0];
  event UpdateTotal(uint totalUser,uint totalSupply);
  event Exchange(address indexed user,uint256 amount);
  event Destory(address indexed user,uint256 amount);
  modifier onlyCFO() {
    require(msg.sender == CFO);
    _;
  }
  modifier onlyCustomerService() {
    require(CustomerService[msg.sender] != 0);
    _;
  }
  function GeneNuggetsToken() public {}
  function() public {
    revert();
  }
  function setName(string newName) external onlyOwner {
    name = newName;
  }
  function setSymbol(string newSymbol) external onlyOwner {
    symbol = newSymbol;
  }
  function setCFO(address newCFO) external onlyOwner {
    CFO = newCFO;
  }
  function setExchangeInterval(uint newInterval) external onlyCFO {
    exchangeInterval = newInterval;
  }
  function setExchangeLimit(uint newLimit) external onlyCFO {
    exchangeLimit = newLimit;
  }
  function setExchangeThreshold(uint newThreshold) external onlyCFO {
    exchangeThreshold = newThreshold;
  }
  function setDestroyThreshold(uint newThreshold) external onlyCFO {
    destroyThreshold = newThreshold;
  }
  function addCustomerService(address cs) onlyCFO external {
    CustomerService[cs] = block.timestamp;
  }
  function removeCustomerService(address cs) onlyCFO external {
    CustomerService[cs] = 0;
  }
  function updateTotal(uint256 _userAmount) onlyCFO external {
    require(_userAmount>totalUsers);
    uint newTotalSupply = calTotalSupply(_userAmount);
    require(newTotalSupply<=CAP && newTotalSupply>totalSupply_);
    uint _amount = newTotalSupply.sub(totalSupply_);
    totalSupply_ = newTotalSupply;
    totalUsers = _userAmount;
    emit UpdateTotal(_amount,totalSupply_); 
  }
  function calTotalSupply(uint _userAmount) private view returns (uint ret) {
    uint tokenAmount = 0;
	  for (uint8 i = 0; i < MINING_LAYERS.length ; i++ ) {
	    if(_userAmount < MINING_LAYERS[i+1]) {
	      tokenAmount = tokenAmount.add(MINING_REWARDS[i].mul(_userAmount.sub(MINING_LAYERS[i])));
	      break;
	    }else {
        tokenAmount = tokenAmount.add(MINING_REWARDS[i].mul(MINING_LAYERS[i+1].sub(MINING_LAYERS[i])));
	    }
	  }
	  return tokenAmount;
  }
  function exchange(address user,uint256 _amount) whenNotPaused onlyCustomerService external {
  	require((block.timestamp-CustomerService[msg.sender])>exchangeInterval);
  	require(_amount <= exchangeLimit && _amount >= exchangeThreshold);
    circulatingSupply = circulatingSupply.add(_amount);
    balances[user] = balances[user].add(_amount);
    CustomerService[msg.sender] = block.timestamp;
    emit Exchange(user,_amount);
    emit Transfer(address(0),user,_amount);
  }
  function destory(uint256 _amount) external {  
    require(balances[msg.sender]>=_amount && _amount>destroyThreshold && circulatingSupply>=_amount);
    circulatingSupply = circulatingSupply.sub(_amount);
    balances[msg.sender] = balances[msg.sender].sub(_amount);
    emit Destory(msg.sender,_amount);
    emit Transfer(msg.sender,0x0,_amount);
  }
  function emergencyERC20Drain( ERC20 token, uint amount ) onlyOwner external {
    token.transfer( owner, amount );
  }
}
