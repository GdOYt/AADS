contract owned {
    address public owner;
    constructor () public {
        owner = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function transferOwnerShip(address newOwer) public onlyOwner {
        owner = newOwer;
    }
}
