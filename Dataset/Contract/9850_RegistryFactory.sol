contract RegistryFactory {
    event NewRegistry(address creator, EIP20 token, PLCRVoting plcr, Parameterizer parameterizer, Registry registry);
    ParameterizerFactory public parameterizerFactory;
    ProxyFactory public proxyFactory;
    Registry public canonizedRegistry;
    constructor(ParameterizerFactory _parameterizerFactory) public {
        parameterizerFactory = _parameterizerFactory;
        proxyFactory = parameterizerFactory.proxyFactory();
        canonizedRegistry = new Registry();
    }
    function newRegistryBYOToken(
        EIP20 _token,
        uint[] _parameters,
        string _name
    ) public returns (Registry) {
        Parameterizer parameterizer = parameterizerFactory.newParameterizerBYOToken(_token, _parameters);
        PLCRVoting plcr = parameterizer.voting();
        Registry registry = Registry(proxyFactory.createProxy(canonizedRegistry, ""));
        registry.init(_token, plcr, parameterizer, _name);
        emit NewRegistry(msg.sender, _token, plcr, parameterizer, registry);
        return registry;
    }
    function newRegistryWithToken(
        uint _supply,
        string _tokenName,
        uint8 _decimals,
        string _symbol,
        uint[] _parameters,
        string _registryName
    ) public returns (Registry) {
        Parameterizer parameterizer = parameterizerFactory.newParameterizerWithToken(_supply, _tokenName, _decimals, _symbol, _parameters);
        EIP20 token = EIP20(parameterizer.token());
        token.transfer(msg.sender, _supply);
        PLCRVoting plcr = parameterizer.voting();
        Registry registry = Registry(proxyFactory.createProxy(canonizedRegistry, ""));
        registry.init(token, plcr, parameterizer, _registryName);
        emit NewRegistry(msg.sender, token, plcr, parameterizer, registry);
        return registry;
    }
}
