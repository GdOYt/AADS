contract Ownable {
    address public ownerCEO;
    address ownerMoney;  
    address ownerServer;
    address privAddress;
    constructor() public { 
        ownerCEO = msg.sender; 
        ownerServer = msg.sender;
        ownerMoney = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == ownerCEO);
        _;
    }
    modifier onlyServer() {
        require(msg.sender == ownerServer || msg.sender == ownerCEO);
        _;
    }
    function transferOwnership(address add) public onlyOwner {
        if (add != address(0)) {
            ownerCEO = add;
        }
    }
    function transferOwnershipServer(address add) public onlyOwner {
        if (add != address(0)) {
            ownerServer = add;
        }
    } 
    function transferOwnerMoney(address _ownerMoney) public  onlyOwner {
        if (_ownerMoney != address(0)) {
            ownerMoney = _ownerMoney;
        }
    }
    function getOwnerMoney() public view onlyOwner returns(address) {
        return ownerMoney;
    } 
    function getOwnerServer() public view onlyOwner returns(address) {
        return ownerServer;
    }
    function getPrivAddress() public view onlyOwner returns(address) {
        return privAddress;
    }
}
