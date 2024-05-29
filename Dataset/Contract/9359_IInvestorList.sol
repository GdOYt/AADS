contract IInvestorList {
    string public constant ROLE_REGD = "regd";
    string public constant ROLE_REGCF = "regcf";
    string public constant ROLE_REGS = "regs";
    string public constant ROLE_UNKNOWN = "unknown";
    function inList(address addr) public view returns (bool);
    function addAddress(address addr, string role) public;
    function getRole(address addr) public view returns (string);
    function hasRole(address addr, string role) public view returns (bool);
}
