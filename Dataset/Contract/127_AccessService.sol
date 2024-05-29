contract AccessService is AccessAdmin {
    address public addrService;
    address public addrFinance;
    modifier onlyService() {
        require(msg.sender == addrService);
        _;
    }
    modifier onlyFinance() {
        require(msg.sender == addrFinance);
        _;
    }
    function setService(address _newService) external {
        require(msg.sender == addrService || msg.sender == addrAdmin);
        require(_newService != address(0));
        addrService = _newService;
    }
    function setFinance(address _newFinance) external {
        require(msg.sender == addrFinance || msg.sender == addrAdmin);
        require(_newFinance != address(0));
        addrFinance = _newFinance;
    }
    function withdraw(address _target, uint256 _amount) 
        external 
    {
        require(msg.sender == addrFinance || msg.sender == addrAdmin);
        require(_amount > 0);
        address receiver = _target == address(0) ? addrFinance : _target;
        uint256 balance = address(this).balance;
        if (_amount < balance) {
            receiver.transfer(_amount);
        } else {
            receiver.transfer(address(this).balance);
        }      
    }
}
