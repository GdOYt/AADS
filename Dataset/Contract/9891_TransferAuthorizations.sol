contract TransferAuthorizations is Ownable, ITransferAuthorizations {
    mapping(address => mapping(address => uint)) public authorizations;
    address public controller;
    event TransferAuthorizationSet(address from, address to, uint expiry);
    function setController(address _controller) public onlyOwner {
        controller = _controller;
    }
    modifier onlyController() {
        assert(msg.sender == controller);
        _;
    }
    function set(address from, address to, uint expiry) public onlyController {
        require(from != 0);
        authorizations[from][to] = expiry;
        emit TransferAuthorizationSet(from, to, expiry);
    }
    function get(address from, address to) public view returns (uint) {
        return authorizations[from][to];
    }
}
