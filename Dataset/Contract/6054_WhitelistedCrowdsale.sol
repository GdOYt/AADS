contract WhitelistedCrowdsale is Crowdsale, Ownable {
    Whitelist public whitelist;
    constructor (Whitelist _whitelist) public {
        require(_whitelist != address(0));
        whitelist = _whitelist;
    }
    modifier onlyWhitelisted(address _beneficiary) {
        require(whitelist.whitelist(_beneficiary));
        _;
    }
    function isWhitelisted(address _beneficiary) public view returns(bool) {
        return whitelist.whitelist(_beneficiary);
    }
    function changeWhitelist(Whitelist _whitelist) public onlyOwner {
        whitelist = _whitelist;
    }
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal onlyWhitelisted(_beneficiary) {
        super._preValidatePurchase(_beneficiary, _weiAmount);
    }
}
