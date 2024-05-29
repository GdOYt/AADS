contract RefundVault is Ownable {
    using SafeMath for uint256;
    uint256 public constant DEDUCTION = 3;
    uint256 public totalDeductedValue;
    enum State { Active, Refunding, Closed }
    mapping (address => uint256) public deposited;
    address public wallet;
    State public state;
    event Closed();
    event RefundsEnabled();
    event Refunded(address indexed beneficiary, uint256 weiAmount);
    constructor(address _wallet) public {
        require(_wallet != address(0));
        wallet = _wallet;
        state = State.Active;
    }
    function deposit(address investor) onlyOwner external payable {
        require(state == State.Active);
        deposited[investor] = deposited[investor].add(msg.value);
    }
    function close() onlyOwner external {
        require(state == State.Active);
        state = State.Closed;
        emit Closed();
        wallet.transfer(address(this).balance);
    }
    function enableRefunds() external onlyOwner {
        require(state == State.Active);
        state = State.Refunding;
        emit RefundsEnabled();
    }
    function refund(address investor) external {
        require(state == State.Refunding);
        uint256 depositedValue = deposited[investor];
        uint256 deductedValue = depositedValue.mul(DEDUCTION).div(100);
        deposited[investor] = 0;
        wallet.transfer(deductedValue);
        investor.transfer(depositedValue.sub(deductedValue));
        totalDeductedValue = totalDeductedValue.add(deductedValue);
        emit Refunded(investor, depositedValue);
    }
}
