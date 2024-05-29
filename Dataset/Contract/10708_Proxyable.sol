contract Proxyable is Owned {
    Proxy public proxy;
    address messageSender; 
    constructor(address _proxy, address _owner)
        Owned(_owner)
        public
    {
        proxy = Proxy(_proxy);
        emit ProxyUpdated(_proxy);
    }
    function setProxy(address _proxy)
        external
        onlyOwner
    {
        proxy = Proxy(_proxy);
        emit ProxyUpdated(_proxy);
    }
    function setMessageSender(address sender)
        external
        onlyProxy
    {
        messageSender = sender;
    }
    modifier onlyProxy {
        require(Proxy(msg.sender) == proxy);
        _;
    }
    modifier optionalProxy
    {
        if (Proxy(msg.sender) != proxy) {
            messageSender = msg.sender;
        }
        _;
    }
    modifier optionalProxy_onlyOwner
    {
        if (Proxy(msg.sender) != proxy) {
            messageSender = msg.sender;
        }
        require(messageSender == owner);
        _;
    }
    event ProxyUpdated(address proxyAddress);
}
