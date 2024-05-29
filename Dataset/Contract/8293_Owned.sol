contract Owned {
    address public owner;
    address public newOwner;
    address internal admin;
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    modifier onlyAdmin {
        require(msg.sender == admin || msg.sender == owner);
        _;
    }
    event OwnershipTransferred(address indexed _from, address indexed _to);
    event AdminChanged(address indexed _from, address indexed _to);
    function Owned() public {
        owner = msg.sender;
        admin = msg.sender;
    }
    function setAdmin(address newAdmin) public onlyOwner{
        emit AdminChanged(admin, newAdmin);
        admin = newAdmin;
    }
    function showAdmin() public view onlyAdmin returns(address _admin){
        _admin = admin;
        return _admin;
    }
    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}
