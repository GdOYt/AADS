contract UserAuth {
    event LogSetOwner(address indexed owner);
    address public owner;
    modifier auth {
        require(isAuth(msg.sender), "permission-denied");
        _;
    }
    function setOwner(address nextOwner) public auth {
        require(nextOwner != address(0x0), "invalid-address");
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
