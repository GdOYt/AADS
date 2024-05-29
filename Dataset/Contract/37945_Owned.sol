contract Owned {
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    address public owner;
    function Owned() {
        owner = msg.sender;
    }
    address public newOwner;
    function changeOwner(address _newOwner) onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() {
        if (msg.sender == newOwner) {
            owner = newOwner;
        }
    }
}
