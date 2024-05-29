contract HouseManaged is Owned {
    address public houseAddress;
    address newOwner;
    bool public isStopped;
    event LOG_ContractStopped();
    event LOG_ContractResumed();
    event LOG_OwnerAddressChanged(address oldAddr, address newOwnerAddress);
    event LOG_HouseAddressChanged(address oldAddr, address newHouseAddress);
    modifier onlyIfNotStopped {
        assert(!isStopped);
        _;
    }
    modifier onlyIfStopped {
        assert(isStopped);
        _;
    }
    function HouseManaged() {
        houseAddress = msg.sender;
    }
    function stop_or_resume_Contract(bool _isStopped)
        onlyOwner {
        isStopped = _isStopped;
    }
    function changeHouse(address _newHouse)
        onlyOwner {
        assert(_newHouse != address(0x0)); 
        houseAddress = _newHouse;
        LOG_HouseAddressChanged(houseAddress, _newHouse);
    }
    function changeOwner(address _newOwner) onlyOwner {
        newOwner = _newOwner; 
    }     
    function acceptOwnership() {
        if (msg.sender == newOwner) {
            owner = newOwner;       
            LOG_OwnerAddressChanged(owner, newOwner);
            delete newOwner;
        }
    }
}
