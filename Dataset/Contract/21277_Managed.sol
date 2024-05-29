contract Managed {
  event Commission(uint256 basisPoint);
  address public manager;
  uint256 public commission;
  function Managed() public {
    manager = msg.sender;
  }
  function() public payable {}
  function setCommission(uint256 _commission) external {
    require(_commission < 10000);
    commission = _commission;
    emit Commission(commission);
  }
  function withdrawBalance() external {
    manager.transfer(address(this).balance);
  }
  function transferPower(address _newManager) external onlyManager {
    manager = _newManager;
  }
  function callFor(address _to, uint256 _value, uint256 _gas, bytes _code)
    external
    payable
    onlyManager
    returns (bool)
  {
    return _to.call.value(_value).gas(_gas)(_code);
  }
  modifier onlyManager
  {
    require(msg.sender == manager);
    _;
  }
}
