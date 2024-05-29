contract Farm {
  mapping (address => address) public crops;
  event CreateCrop(address indexed owner, address indexed crop);
  function create(address _referrer) external payable {
    require(crops[msg.sender] == address(0));
    crops[msg.sender] = (new ProxyCrop).value(msg.value)(msg.sender, _referrer);
    emit CreateCrop(msg.sender, crops[msg.sender]);
  }
}
