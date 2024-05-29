contract CrowdsaleWPTByRounds is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for ERC20;
  ERC20 public token;
  address public wallet;
  Token public minterContract;
  uint256 public rate;
  uint256 public tokensRaised;
  uint256 public cap;
  uint256 public openingTime;
  uint256 public closingTime;
  uint public minInvestmentValue;
  bool public checksOn;
  uint256 public gasAmount;
  function setMinter(address _minterAddr) public onlyOwner {
    minterContract = Token(_minterAddr);
  }
  modifier onlyWhileOpen {
    require(block.timestamp >= openingTime && block.timestamp <= closingTime);
    _;
  }
  event TokenPurchase(
    address indexed purchaser,
    address indexed beneficiary,
    uint256 value,
    uint256 amount
    );
  event TokensTransfer(
    address indexed _from,
    address indexed _to,
    uint256 amount,
    bool isDone
    );
constructor () public {
    rate = 400;
    wallet = 0xeA9cbceD36a092C596e9c18313536D0EEFacff46;
    cap = 400000000000000000000000;
    openingTime = 1534558186;
    closingTime = 1535320800;
    minInvestmentValue = 0.02 ether;
    checksOn = true;
    gasAmount = 25000;
  }
  function capReached() public view returns (bool) {
    return tokensRaised >= cap;
  }
  function changeRate(uint256 newRate) public onlyOwner {
    rate = newRate;
  }
  function closeRound() public onlyOwner {
    closingTime = block.timestamp + 1;
  }
  function setToken(ERC20 _token) public onlyOwner {
    token = _token;
  }
  function setWallet(address _wallet) public onlyOwner {
    wallet = _wallet;
  }
  function changeMinInvest(uint256 newMinValue) public onlyOwner {
    rate = newMinValue;
  }
  function setChecksOn(bool _checksOn) public onlyOwner {
    checksOn = _checksOn;
  }
  function setGasAmount(uint256 _gasAmount) public onlyOwner {
    gasAmount = _gasAmount;
  }
  function setCap(uint256 _newCap) public onlyOwner {
    cap = _newCap;
  }
  function startNewRound(uint256 _rate, address _wallet, ERC20 _token, uint256 _cap, uint256 _openingTime, uint256 _closingTime) payable public onlyOwner {
    require(!hasOpened());
    rate = _rate;
    wallet = _wallet;
    token = _token;
    cap = _cap;
    openingTime = _openingTime;
    closingTime = _closingTime;
  }
  function hasClosed() public view returns (bool) {
    return block.timestamp > closingTime;
  }
  function hasOpened() public view returns (bool) {
    return (openingTime < block.timestamp && block.timestamp < closingTime);
  }
  function () payable external {
    buyTokens(msg.sender);
  }
  function buyTokens(address _beneficiary) payable public{
    uint256 weiAmount = msg.value;
    if (checksOn) {
        _preValidatePurchase(_beneficiary, weiAmount);
    }
    uint256 tokens = _getTokenAmount(weiAmount);
    tokensRaised = tokensRaised.add(tokens);
    minterContract.mint(_beneficiary, tokens);
    emit TokenPurchase(
      msg.sender,
      _beneficiary,
      weiAmount,
      tokens
    );
    _forwardFunds();
  }
  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount)
  internal
  view
  onlyWhileOpen
  {
    require(_beneficiary != address(0));
    require(_weiAmount != 0 && _weiAmount > minInvestmentValue);
    require(tokensRaised.add(_getTokenAmount(_weiAmount)) <= cap);
  }
  function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
    token.safeTransfer(_beneficiary, _tokenAmount);
  }
  function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
    _deliverTokens(_beneficiary, _tokenAmount);
  }
  function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
    return _weiAmount.mul(rate);
  }
  function _forwardFunds() internal {
    bool isTransferDone = wallet.call.value(msg.value).gas(gasAmount)();
    emit TokensTransfer (
        msg.sender,
        wallet,
        msg.value,
        isTransferDone
        );
  }
}
