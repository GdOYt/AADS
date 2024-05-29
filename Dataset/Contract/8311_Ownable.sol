contract Ownable {
    address public owner;
    function Ownable() {
        owner = msg.sender;
    }
    function transferOwnership(address newOwner) onlyOwner {
        if (newOwner != address(0))
            owner = newOwner;
    }
    function kill() {
        if (msg.sender == owner)
            selfdestruct(owner);
    }
    modifier onlyOwner() {
        if (msg.sender == owner)
            _;
    }
}
