contract AuthorizedList {
    bytes32 constant PRESIDENT = keccak256("Republics President!");
    bytes32 constant STAFF_MEMBER = keccak256("Staff Member.");
    bytes32 constant AIR_DROP = keccak256("Airdrop Permission.");
    bytes32 constant INTERNAL = keccak256("Internal Authorization.");
    mapping (address => mapping(bytes32 => bool)) authorized;
}
