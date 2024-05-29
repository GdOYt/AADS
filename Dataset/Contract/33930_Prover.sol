contract Prover {
    using Sets for Sets.addressSet;
    using Sets for Sets.bytes32Set;
    address owner;
    Sets.addressSet users;
    mapping(address => Account) internal accounts;
    struct Account {
        Sets.bytes32Set entries;
        mapping(bytes32 => Entry) values;
    }
    struct Entry {
        uint time;
        uint staked;
    }
    function Prover() public {
        owner = msg.sender;
    }
    function() internal {
        if (! this.delegatecall(msg.data)) {
            revert();
        }
    }
    modifier entryExists(address target, bytes32 dataHash, bool exists) {
        assert(accounts[target].entries.contains(dataHash) == exists);
        _;
    }
    function registeredUsers()
        external
        view
        returns (uint number_unique_addresses, address[] unique_addresses) {
        return (users.length(), users.members);
    }
    function userEntries(address target)
        external
        view
        returns (bytes32[]) {
        return accounts[target].entries.members;
    }
    function entryInformation(address target, bytes32 dataHash)
        external
        view
        returns (bool proved, uint time, uint staked) {
        return (accounts[target].entries.contains(dataHash),
                accounts[target].values[dataHash].time,
                accounts[target].values[dataHash].staked);
    }
    function addEntry(bytes32 dataHash)
        public
        payable
        entryExists(msg.sender, dataHash, false){
        users.insert(msg.sender);
        accounts[msg.sender].entries.insert(dataHash);
        accounts[msg.sender].values[dataHash] = Entry(now, msg.value);
    }
    function deleteEntry(bytes32 dataHash)
        public
        entryExists(msg.sender, dataHash, true) {
        uint rebate = accounts[msg.sender].values[dataHash].staked;
        delete accounts[msg.sender].values[dataHash];
        accounts[msg.sender].entries.remove(dataHash);
        if (accounts[msg.sender].entries.length() == 0) {
            users.remove(msg.sender);
        }
        if (rebate > 0) msg.sender.transfer(rebate);
    }
    function selfDestruct() public {
        if ((msg.sender == owner) && (users.length() == 0)) {
            selfdestruct(owner);
        }
    }
}
