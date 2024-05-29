contract Ownable {
    address public ethFundDeposit;
    event OwnershipTransferred(address indexed ethFundDeposit, address indexed _newFundDeposit);
    constructor() public {
        ethFundDeposit = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == ethFundDeposit);
        _;
    }
    function transferOwnership(address _newFundDeposit) public onlyOwner {
        require(_newFundDeposit != address(0));
        emit OwnershipTransferred(ethFundDeposit, _newFundDeposit);
        ethFundDeposit = _newFundDeposit;
    }
}
