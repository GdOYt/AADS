contract OnlyWhiteListedAddresses is Ownable {
    using SafeMath for uint256;
    address utilityAccount;
    mapping (address => bool) whitelist;
    mapping (address => address) public referrals;
    modifier onlyOwnerOrUtility() {
        require(msg.sender == owner || msg.sender == utilityAccount);
        _;
    }
    event WhitelistedAddresses(
        address[] users
    );
    event ReferralsAdded(
        address[] user,
        address[] referral
    );
    function OnlyWhiteListedAddresses(address _utilityAccount) public {
        utilityAccount = _utilityAccount;
    }
    function whitelistAddress (address[] users) public onlyOwnerOrUtility {
        for (uint i = 0; i < users.length; i++) {
            whitelist[users[i]] = true;
        }
        WhitelistedAddresses(users);
    }
    function addAddressReferrals (address[] users, address[] _referrals) public onlyOwnerOrUtility {
        require(users.length == _referrals.length);
        for (uint i = 0; i < users.length; i++) {
            require(isWhiteListedAddress(users[i]));
            referrals[users[i]] = _referrals[i];
        }
        ReferralsAdded(users, _referrals);
    }
    function isWhiteListedAddress (address addr) public view returns (bool) {
        return whitelist[addr];
    }
}
