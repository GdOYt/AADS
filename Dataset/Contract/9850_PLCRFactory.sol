contract PLCRFactory {
  event newPLCR(address creator, EIP20 token, PLCRVoting plcr);
  ProxyFactory public proxyFactory;
  PLCRVoting public canonizedPLCR;
  constructor() {
    canonizedPLCR = new PLCRVoting();
    proxyFactory = new ProxyFactory();
  }
  function newPLCRBYOToken(EIP20 _token) public returns (PLCRVoting) {
    PLCRVoting plcr = PLCRVoting(proxyFactory.createProxy(canonizedPLCR, ""));
    plcr.init(_token);
    emit newPLCR(msg.sender, _token, plcr);
    return plcr;
  }
  function newPLCRWithToken(
    uint _supply,
    string _name,
    uint8 _decimals,
    string _symbol
  ) public returns (PLCRVoting) {
    EIP20 token = new EIP20(_supply, _name, _decimals, _symbol);
    token.transfer(msg.sender, _supply);
    PLCRVoting plcr = PLCRVoting(proxyFactory.createProxy(canonizedPLCR, ""));
    plcr.init(token);
    emit newPLCR(msg.sender, token, plcr);
    return plcr;
  }
}
