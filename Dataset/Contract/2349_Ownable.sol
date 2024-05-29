contract Ownable {
    address public owner=0x28970854Bfa61C0d6fE56Cc9daAAe5271CEaEC09;
    constructor()public {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        owner = newOwner;
    }
}
