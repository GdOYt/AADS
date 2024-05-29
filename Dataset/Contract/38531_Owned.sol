contract Owned is Base {
    address public owner;
    address public newOwner;
    function Owned() {
        owner = msg.sender;
    }
    function transferOwnership(address _newOwner) only(owner) {
        newOwner = _newOwner;
    }
    function acceptOwnership() only(newOwner) {
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
    event OwnershipTransferred(address indexed _from, address indexed _to);
}
