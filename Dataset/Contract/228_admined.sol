contract admined { 
    address public admin; 
    mapping(address => uint256) public level; 
    bool public lockSupply; 
    constructor() public {
        admin = 0x6585b849371A40005F9dCda57668C832a5be1777; 
        level[admin] = 2;
        emit Admined(admin);
    }
    modifier onlyAdmin(uint8 _level) { 
        require(msg.sender == admin || level[msg.sender] >= _level);
        _;
    }
    modifier supplyLock() { 
        require(lockSupply == false);
        _;
    }
    function transferAdminship(address _newAdmin) onlyAdmin(2) public { 
        require(_newAdmin != address(0));
        admin = _newAdmin;
        level[_newAdmin] = 2;
        emit TransferAdminship(admin);
    }
    function setAdminLevel(address _target, uint8 _level) onlyAdmin(2) public {
        level[_target] = _level;
        emit AdminLevelSet(_target,_level);
    }
    function setSupplyLock(bool _set) onlyAdmin(2) public { 
        lockSupply = _set;
        emit SetSupplyLock(_set);
    }
    event SetSupplyLock(bool _set);
    event TransferAdminship(address newAdminister);
    event Admined(address administer);
    event AdminLevelSet(address _target,uint8 _level);
}
