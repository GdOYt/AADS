contract RefundableDaonomicCrowdsale is DaonomicCrowdsale {
  event Refund(address _address, uint256 investment);
  mapping(address => uint256) public investments;
  function claimRefund() public {
    require(isRefundable());
    require(investments[msg.sender] > 0);
    uint investment = investments[msg.sender];
    investments[msg.sender] = 0;
    msg.sender.transfer(investment);
    emit Refund(msg.sender, investment);
  }
  function isRefundable() public view returns (bool);
  function _updatePurchasingState(
    address _beneficiary,
    uint256 _weiAmount,
    uint256 _tokens
  ) internal {
    super._updatePurchasingState(_beneficiary, _weiAmount, _tokens);
    investments[_beneficiary] = investments[_beneficiary].add(_weiAmount);
  }
}
