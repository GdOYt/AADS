contract ProxyRegistry {
    mapping(address => DSProxy) public proxies;
    DSProxyFactory factory;
    constructor(DSProxyFactory factory_) public {
        factory = factory_;
    }
    function build() public returns (DSProxy proxy) {
        proxy = build(msg.sender);
    }
    function build(address owner) public returns (DSProxy proxy) {
        require(proxies[owner] == DSProxy(0) || proxies[owner].owner() != owner);  
        proxy = factory.build(owner);
        proxies[owner] = proxy;
    }
}
