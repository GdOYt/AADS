contract InvestorList is Ownable, IInvestorList {
    event AddressAdded(address addr, string role);
    event AddressRemoved(address addr, string role);
    mapping (address => string) internal investorList;
    modifier validRole(string role) {
        require(
            keccak256(bytes(role)) == keccak256(bytes(ROLE_REGD)) ||
            keccak256(bytes(role)) == keccak256(bytes(ROLE_REGCF)) ||
            keccak256(bytes(role)) == keccak256(bytes(ROLE_REGS)) ||
            keccak256(bytes(role)) == keccak256(bytes(ROLE_UNKNOWN))
        );
        _;
    }
    function inList(address addr)
        public
        view
        returns (bool)
    {
        if (bytes(investorList[addr]).length != 0) {
            return true;
        } else {
            return false;
        }
    }
    function getRole(address addr)
        public
        view
        returns (string)
    {
        require(inList(addr));
        return investorList[addr];
    }
    function hasRole(address addr, string role)
        public
        view
        returns (bool)
    {
        return keccak256(bytes(role)) == keccak256(bytes(investorList[addr]));
    }
    function addAddress(address addr, string role)
        onlyOwner
        validRole(role)
        public
    {
        investorList[addr] = role;
        emit AddressAdded(addr, role);
    }
    function addAddresses(address[] addrs, string role)
        onlyOwner
        validRole(role)
        public
    {
        for (uint256 i = 0; i < addrs.length; i++) {
            addAddress(addrs[i], role);
        }
    }
    function removeAddress(address addr)
        onlyOwner
        public
    {
        require(inList(addr));
        string memory role = investorList[addr];
        investorList[addr] = "";
        emit AddressRemoved(addr, role);
    }
    function removeAddresses(address[] addrs)
        onlyOwner
        public
    {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (inList(addrs[i])) {
                removeAddress(addrs[i]);
            }
        }
    }
}
