contract TinyProxyFactory {
  mapping(address => mapping(address => address)) public proxyFor;
  function make(address to, uint gas,  bool track) public returns(address proxy){
    proxy = new TinyProxy(to, gas);
    if(track && proxyFor[to][msg.sender] == 0x0) {
     proxyFor[msg.sender][to] = proxy; 
    } 
    return proxy;
  }
}
