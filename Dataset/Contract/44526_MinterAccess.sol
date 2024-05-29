contract MinterAccess is Ownable, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    modifier onlyMinter {
        require(hasRole(MINTER_ROLE, _msgSender()), "MinterAccess: Sender is not a minter");
        _;
    }
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
    }
    function addMinter(address account) external {
        grantRole(MINTER_ROLE, account);
    }
    function renounceMinter(address account) external {
        renounceRole(MINTER_ROLE, account);
    }
    function revokeMinter(address account) external {
        revokeRole(MINTER_ROLE, account);
    }
}
