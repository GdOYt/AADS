contract CrowdsaleProxyFactory {
    address public targetCrowdsale;
    address public targetToken;
    address private personalCrowdsaleProxyTarget;
    event ProxyCreated(address proxy, address beneficiary);
    function CrowdsaleProxyFactory(address _targetCrowdsale, address _targetToken) public {
        targetCrowdsale = _targetCrowdsale;
        targetToken = _targetToken;
        personalCrowdsaleProxyTarget = new PersonalCrowdsaleProxy();
    }
    function createProxyAddress() public returns (address) {
        address proxy = new CrowdsaleProxy(msg.sender, targetCrowdsale);
        ProxyCreated(proxy, msg.sender);
        return proxy;
    }
    function createProxyAddressFor(address _beneficiary) public returns (address) {
        address proxy = new CrowdsaleProxy(_beneficiary, targetCrowdsale);
        ProxyCreated(proxy, _beneficiary);
        return proxy;
    }
    function createPersonalDepositAddress(bytes32 _passphraseHash) public returns (address) {
        address proxy = new PersonalCrowdsaleProxyDispatcher(
            personalCrowdsaleProxyTarget, targetCrowdsale, targetToken, _passphraseHash);
        ProxyCreated(proxy, msg.sender);
        return proxy;
    }
    function createPersonalDepositAddressFor(address _beneficiary) public returns (address) {
        PersonalCrowdsaleProxy proxy = PersonalCrowdsaleProxy(new PersonalCrowdsaleProxyDispatcher(
            personalCrowdsaleProxyTarget, targetCrowdsale, targetToken, keccak256(bytes32(_beneficiary))));
        proxy.setBeneficiary(_beneficiary, bytes32(_beneficiary));
        ProxyCreated(proxy, _beneficiary);
        return proxy;
    }
}
