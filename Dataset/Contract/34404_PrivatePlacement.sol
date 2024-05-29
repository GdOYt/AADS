contract PrivatePlacement is Ownable {
  using SafeMath for uint;
  address public multisig;
  ABHCoin public token;
  uint256 public hardcap;
  uint public rate;
  bool refundAllowed;
  bool privatePlacementIsOn = true;
  bool PrivatePlacementFinished = false;
  mapping(address => uint) public balances;
  function PrivatePlacement(address _ABHCoinAddress, address _multisig, uint _rate) {
    multisig = _multisig;
    rate = _rate * 1 ether;
    hardcap = 120600000 * 1 ether;  
    token = ABHCoin(_ABHCoinAddress);
  }
  modifier isUnderHardCap() {
    require(token.totalSupply() <= hardcap);
    _;
  }
  function stopPrivatePlacement() onlyOwner {
    privatePlacementIsOn = false;
  }
  function restartPrivatePlacement() onlyOwner {
    require(!PrivatePlacementFinished);
    privatePlacementIsOn = true;
  }
  function finishPrivatePlacement() onlyOwner {
    require(!refundAllowed);
    multisig.transfer(this.balance);
    privatePlacementIsOn = false;
    PrivatePlacementFinished = true;
  }
  function alloweRefund() onlyOwner {
    refundAllowed = true;
  }
  function refund() public {
    require(refundAllowed);
    uint valueToReturn = balances[msg.sender];
    balances[msg.sender] = 0;
    msg.sender.transfer(valueToReturn);
  }
  function createTokens() isUnderHardCap payable {
    require(privatePlacementIsOn);
    uint valueWEI = msg.value;
    uint tokens = rate.mul(msg.value).div(1 ether);
    if (token.totalSupply() + tokens > hardcap){
      tokens = hardcap - token.totalSupply();
      valueWEI = tokens.mul(1 ether).div(rate);
      token.mint(msg.sender, tokens);
      uint change = msg.value - valueWEI;
      bool isSent = msg.sender.call.gas(3000000).value(change)();
    require(isSent);
    } else {
      token.mint(msg.sender, tokens);
    }
    balances[msg.sender] = balances[msg.sender].add(valueWEI);
  }
  function changeRate(uint _rate) onlyOwner {
     rate = _rate; 
  }
  function() external payable {
    createTokens();
  }
}
