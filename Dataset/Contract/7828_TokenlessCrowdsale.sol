contract TokenlessCrowdsale {
  using SafeMath for uint256;
  address public wallet;
  uint256 public weiRaised;
  event SaleContribution(address indexed purchaser, address indexed beneficiary, uint256 value);
  constructor (address _wallet) public {
    require(_wallet != address(0));
    wallet = _wallet;
  }
  function () external payable {
    buyTokens(msg.sender);
  }
  function buyTokens(address _beneficiary) public payable {
    uint256 weiAmount = msg.value;
    _preValidatePurchase(_beneficiary, weiAmount);
    weiRaised = weiRaised.add(weiAmount);
    _processPurchaseInWei(_beneficiary, weiAmount);
    emit SaleContribution(
      msg.sender,
      _beneficiary,
      weiAmount
    );
    _updatePurchasingState(_beneficiary, weiAmount);
    _forwardFunds();
    _postValidatePurchase(_beneficiary, weiAmount);
  }
  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
    require(_beneficiary != address(0));
    require(_weiAmount != 0);
  }
  function _postValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
  }
  function _processPurchaseInWei(address _beneficiary, uint256 _weiAmount) internal {
  }
  function _updatePurchasingState(address _beneficiary, uint256 _weiAmount) internal {
  }
  function _forwardFunds() internal {
    wallet.transfer(msg.value);
  }
}
