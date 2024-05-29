contract Owned is OwnedI {
    address private owner;
    function Owned() {
        owner = msg.sender;
    }
    modifier fromOwner {
        if (msg.sender != owner) {
            throw;
        }
        _;
    }
    function getOwner()
        constant
        returns (address) {
        return owner;
    }
    function setOwner(address newOwner)
        fromOwner 
        returns (bool success) {
        if (newOwner == 0) {
            throw;
        }
        if (owner != newOwner) {
            LogOwnerChanged(owner, newOwner);
            owner = newOwner;
        }
        success = true;
    }
}
