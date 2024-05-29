contract ProxyOwnable {
  address public proxyOwner;
  event ProxyOwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  constructor() public {
    proxyOwner = msg.sender;
  }
  modifier onlyOwner() {
    require(msg.sender == proxyOwner);
    _;
  }
  function transferProxyOwnership(address _newOwner) public onlyOwner {
    require(_newOwner != address(0));
    emit ProxyOwnershipTransferred(proxyOwner, _newOwner);
    proxyOwner = _newOwner;
  }
}
