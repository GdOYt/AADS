contract AuthorizedList {
    bytes32 constant I_AM_ROOT = keccak256("I am root!");
    bytes32 constant STAFF_MEMBER = keccak256("Staff Member.");
    bytes32 constant ROUTER = keccak256("Router Contract.");
    mapping (address => mapping(bytes32 => bool)) authorized;
    mapping (bytes32 => bool) internal contractPermissions;
}
