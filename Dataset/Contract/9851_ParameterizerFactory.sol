contract ParameterizerFactory {
    event NewParameterizer(address creator, address token, address plcr, Parameterizer parameterizer);
    PLCRFactory public plcrFactory;
    ProxyFactory public proxyFactory;
    Parameterizer public canonizedParameterizer;
    constructor(PLCRFactory _plcrFactory) public {
        plcrFactory = _plcrFactory;
        proxyFactory = plcrFactory.proxyFactory();
        canonizedParameterizer = new Parameterizer();
    }
    function newParameterizerBYOToken(
        EIP20 _token,
        uint[] _parameters
    ) public returns (Parameterizer) {
        PLCRVoting plcr = plcrFactory.newPLCRBYOToken(_token);
        Parameterizer parameterizer = Parameterizer(proxyFactory.createProxy(canonizedParameterizer, ""));
        parameterizer.init(
            _token,
            plcr,
            _parameters
        );
        emit NewParameterizer(msg.sender, _token, plcr, parameterizer);
        return parameterizer;
    }
    function newParameterizerWithToken(
        uint _supply,
        string _name,
        uint8 _decimals,
        string _symbol,
        uint[] _parameters
    ) public returns (Parameterizer) {
        PLCRVoting plcr = plcrFactory.newPLCRWithToken(_supply, _name, _decimals, _symbol);
        EIP20 token = EIP20(plcr.token());
        token.transfer(msg.sender, _supply);
        Parameterizer parameterizer = Parameterizer(proxyFactory.createProxy(canonizedParameterizer, ""));
        parameterizer.init(
            token,
            plcr,
            _parameters
        );
        emit NewParameterizer(msg.sender, token, plcr, parameterizer);
        return parameterizer;
    }
}
