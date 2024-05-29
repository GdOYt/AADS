contract PersonalCrowdsaleProxyDispatcher is SimpleDispatcher {
    address public targetCrowdsale;
    address public targetToken;
    address public beneficiary;
    bytes32 private passphraseHash;
    function PersonalCrowdsaleProxyDispatcher(address _target, address _targetCrowdsale, address _targetToken, bytes32 _passphraseHash) public 
        SimpleDispatcher(_target) {
        targetCrowdsale = _targetCrowdsale;
        targetToken = _targetToken;
        passphraseHash = _passphraseHash;
    }
}
