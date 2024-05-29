contract PersonalCrowdsaleProxy is IPersonalCrowdsaleProxy, Dispatchable {
    ICrowdsale public targetCrowdsale;
    IToken public targetToken;
    address public beneficiary;
    bytes32 private passphraseHash;
    modifier when_beneficiary_is_known() {
        require(beneficiary != address(0));
        _;
    }
    modifier when_beneficiary_is_unknown() {
        require(beneficiary == address(0));
        _;
    }
    function setBeneficiary(address _beneficiary, bytes32 _passphrase) public when_beneficiary_is_unknown {
        require(keccak256(_passphrase) == passphraseHash);
        beneficiary = _beneficiary;
    }
    function () public payable {
    }
    function invest() public {
        targetCrowdsale.contribute.value(this.balance)();
    }
    function refund() public {
        targetCrowdsale.refund();
    }
    function updateTokenBalance() public {
        targetCrowdsale.withdrawTokens();
    }
    function withdrawTokens() public when_beneficiary_is_known {
        uint balance = targetToken.balanceOf(this);
        targetToken.transfer(beneficiary, balance);
    }
    function updateEtherBalance() public {
        targetCrowdsale.withdrawEther();
    }
    function withdrawEther() public when_beneficiary_is_known {
        beneficiary.transfer(this.balance);
    }
}
