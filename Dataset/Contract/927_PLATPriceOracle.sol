contract PLATPriceOracle {
  mapping (address => bool) admins;
  uint256 public ETHPrice = 60000000000000000000000;
  event PriceChanged(uint256 newPrice);
  function PLATPriceOracle() public {
    admins[msg.sender] = true;
  }
  function updatePrice(uint256 _newPrice) public {
    require(_newPrice > 0);
    require(admins[msg.sender] == true);
    ETHPrice = _newPrice;
    PriceChanged(_newPrice);
  }
  function setAdmin(address _newAdmin, bool _value) public {
    require(admins[msg.sender] == true);
    admins[_newAdmin] = _value;
  }
}
