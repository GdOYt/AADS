contract Ownable {
    address public owner;
    address public newOwnerCandidate;
    event OwnershipRequested(address indexed by, address indexed to);
    event OwnershipTransferred(address indexed from, address indexed to);
    function Ownable() public {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    modifier onlyOwnerCandidate() {
        require(msg.sender == newOwnerCandidate);
        _;
    }
    function requestOwnershipTransfer(address _newOwnerCandidate) external onlyOwner {
        require(_newOwnerCandidate != address(0));
        newOwnerCandidate = _newOwnerCandidate;
        OwnershipRequested(msg.sender, newOwnerCandidate);
    }
    function acceptOwnership() external onlyOwnerCandidate {
        address previousOwner = owner;
        owner = newOwnerCandidate;
        newOwnerCandidate = address(0);
        OwnershipTransferred(previousOwner, owner);
    }
}
