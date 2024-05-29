contract IXTPaymentContract is Ownable, EmergencySafe, Upgradeable{
  event IXTPayment(address indexed from, address indexed to, uint value, string indexed action);
  ERC20Interface public tokenContract;
  mapping(string => uint) private actionPrices;
  mapping(address => bool) private allowed;
  modifier allowedOnly() {
    require(allowed[msg.sender] || msg.sender == owner);
    _;
  }
  function IXTPaymentContract(address tokenAddress) public {
    tokenContract = ERC20Interface(tokenAddress);
    allowed[owner] = true;
  }
  function transferIXT(address from, address to, string action) public allowedOnly isNotPaused returns (bool) {
    if (isOldVersion) {
      IXTPaymentContract newContract = IXTPaymentContract(nextContract);
      return newContract.transferIXT(from, to, action);
    } else {
      uint price = actionPrices[action];
      if(price != 0 && !tokenContract.transferFrom(from, to, price)){
        return false;
      } else {
        emit IXTPayment(from, to, price, action);     
        return true;
      }
    }
  }
  function setTokenAddress(address erc20Token) public ownerOnly isNotPaused {
    tokenContract = ERC20Interface(erc20Token);
  }
  function setAction(string action, uint price) public ownerOnly isNotPaused {
    actionPrices[action] = price;
  }
  function getActionPrice(string action) public view returns (uint) {
    return actionPrices[action];
  }
  function setAllowed(address allowedAddress) public ownerOnly {
    allowed[allowedAddress] = true;
  }
  function removeAllowed(address allowedAddress) public ownerOnly {
    allowed[allowedAddress] = false;
  }
}
