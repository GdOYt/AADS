contract AdminManager {
    event ChangeOwner(address _oldOwner, address _newOwner);
    event SetAdmin(address _address, bool _isAdmin);
    address public owner;
    mapping(address=>bool) public admins;
    constructor() public {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    modifier onlyAdmins() {
        require(msg.sender == owner || admins[msg.sender]);
        _;
    }
    function changeOwner(address _newOwner) public onlyOwner {
        require(_newOwner != address(0));
        emit ChangeOwner(owner, _newOwner);
        owner = _newOwner;
    }
    function setAdmin(address _address, bool _isAdmin) public onlyOwner {
        emit SetAdmin(_address, _isAdmin);
        if(!_isAdmin){
            delete admins[_address];
        }else{
            admins[_address] = true;
        }
    }
}
