contract admined {
    address public admin;  
    constructor() internal {
        admin = 0x6585b849371A40005F9dCda57668C832a5be1777;  
        emit Admined(admin);
    }
    modifier onlyAdmin() {  
        require(msg.sender == admin);
        _;
    }
    function transferAdminship(address _newAdmin) onlyAdmin public {  
        admin = _newAdmin;
        emit TransferAdminship(admin);
    }
    event TransferAdminship(address newAdminister);
    event Admined(address administer);
}
