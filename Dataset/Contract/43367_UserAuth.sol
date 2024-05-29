contract UserAuth is AddressRecord {
    event LogSetOwner(address indexed owner);
    address public owner;
    modifier auth {
        require(isAuth(msg.sender), "permission-denied");
        _;
    }
    function setOwner(address nextOwner) public auth {
        RegistryInterface(registry).record(owner, nextOwner);
        owner = nextOwner;
        emit LogSetOwner(nextOwner);
    }
    function isAuth(address src) public view returns (bool) {
        if (src == owner) {
            return true;
        } else if (src == address(this)) {
            return true;
        }
        return false;
    }
}
