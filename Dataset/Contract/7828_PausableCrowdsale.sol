contract PausableCrowdsale is TokenlessCrowdsale, Ownable {
  bool public open = true;
  modifier saleIsOpen() {
    require(open);
    _;
  }
  function unpauseSale() external onlyOwner {
    require(!open);
    open = true;
  }
  function pauseSale() external onlyOwner saleIsOpen {
    open = false;
  }
  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal saleIsOpen {
    super._preValidatePurchase(_beneficiary, _weiAmount);
  }
}
