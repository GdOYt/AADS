contract owned {
    address public owner;
    address public tokenContract;
    constructor() public{
        owner = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    modifier onlyOwnerAndtokenContract {
        require(msg.sender == owner || msg.sender == tokenContract);
        _;
    }
    function transferOwnership(address newOwner) onlyOwner public {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
    function transfertokenContract(address newOwner) onlyOwner public {
        if (newOwner != address(0)) {
            tokenContract = newOwner;
        }
    }
}
