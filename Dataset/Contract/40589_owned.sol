contract owned {
    function owned() {
        owner = msg.sender;
    }
    address public owner;
    modifier onlyowner { if (msg.sender != owner) throw; _ }
    event OwnershipTransfer(address indexed from, address indexed to);
    function transferOwnership(address to) public onlyowner {
        owner = to;
        OwnershipTransfer(msg.sender, to);
    }
}
