contract HouseManaged is Owned {
    address public houseAddress;
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
    function changeHouse_and_Owner_Addresses(address newHouse, address newOwner)
        onlyOwner {
        assert(newHouse != address(0x0));
        assert(newOwner != address(0x0));
        owner = newOwner;
        LOG_OwnerAddressChanged(owner, newOwner);
        houseAddress = newHouse;
        LOG_HouseAddressChanged(houseAddress, newHouse);
    }
}
