contract DAOController{
    address public dao;
    modifier onlyDAO{
        if (msg.sender != dao) throw;
        _;
    }
}
