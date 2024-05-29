contract Proxy is ProxyStorage, DelegateProxy {
  event Upgrade(address indexed newContract, bytes initializedWith);
  function upgrade(IApplication newContract, bytes data) public {
    currentContract = newContract;
    newContract.initialize(data);
    Upgrade(newContract, data);
  }
  function () payable public {
    require(currentContract != 0);  
    delegatedFwd(currentContract, msg.data);
  }
}
