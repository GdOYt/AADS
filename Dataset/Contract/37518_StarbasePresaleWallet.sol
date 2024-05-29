contract StarbasePresaleWallet is MultiSigWallet {
    uint256 public maxCap;           
    uint256 public totalPaidAmount;  
    struct WhitelistAddresses {
        uint256 capForAmountRaised;
        uint256 amountRaised;
        bool    bonaFide;
    }
    mapping (address => WhitelistAddresses) public whitelistedAddresses;
    function StarbasePresaleWallet(address[] _owners, uint256 _required, uint256 _maxCap)
        public
        MultiSigWallet(_owners, _required)
    {
        maxCap = _maxCap;
    }
    function whitelistAddress(address addressToWhitelist, uint256 capAmount)
        external
        ownerExists(msg.sender)
    {
        assert(!whitelistedAddresses[addressToWhitelist].bonaFide);
        whitelistedAddresses[addressToWhitelist].bonaFide = true;
        whitelistedAddresses[addressToWhitelist].capForAmountRaised = capAmount;
    }
    function unwhitelistAddress(address addressToUnwhitelist)
        external
        ownerExists(msg.sender)
    {
        assert(whitelistedAddresses[addressToUnwhitelist].bonaFide);
        whitelistedAddresses[addressToUnwhitelist].bonaFide = false;
    }
    function changeWhitelistedAddressCapAmount(address whitelistedAddress, uint256 capAmount)
        external
        ownerExists(msg.sender)
    {
        assert(whitelistedAddresses[whitelistedAddress].bonaFide);
        whitelistedAddresses[whitelistedAddress].capForAmountRaised = capAmount;
    }
    function changeMaxCap(uint256 _maxCap)
        external
        ownerExists(msg.sender)
    {
        assert(totalPaidAmount <= _maxCap);
        maxCap = _maxCap;
    }
    function payment() payable {
        require(msg.value > 0 && this.balance <= maxCap);
        require(whitelistedAddresses[msg.sender].bonaFide);
        whitelistedAddresses[msg.sender].amountRaised = SafeMath.add(msg.value, whitelistedAddresses[msg.sender].amountRaised);
        assert(whitelistedAddresses[msg.sender].amountRaised <= whitelistedAddresses[msg.sender].capForAmountRaised);
        totalPaidAmount = SafeMath.add(totalPaidAmount, msg.value);
        Deposit(msg.sender, msg.value);
    }
    function () payable {
        payment();
    }
}
