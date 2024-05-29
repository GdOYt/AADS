contract RefundSafe is HasOwner {
    using SafeMath for uint256;
    enum State {ACTIVE, REFUNDING, CLOSED}
    mapping(address => uint256) public deposits;
    address public beneficiary;
    State public state;
    event RefundsClosed();
    event RefundsAllowed();
    event RefundSuccessful(address indexed _address, uint256 _value);
    constructor(address _owner, address _beneficiary)
        HasOwner(_owner)
        public
    {
        require(_beneficiary != 0x0);
        beneficiary = _beneficiary;
        state = State.ACTIVE;
    }
    function setBeneficiary(address _beneficiary) public onlyOwner {
        require(_beneficiary != address(0));
        beneficiary = _beneficiary;
    }
    function deposit(address _address) onlyOwner public payable {
        require(state == State.ACTIVE);
        deposits[_address] = deposits[_address].plus(msg.value);
    }
    function close() onlyOwner public {
        require(state == State.ACTIVE);
        state = State.CLOSED;
        emit RefundsClosed();
        beneficiary.transfer(address(this).balance);
    }
    function allowRefunds() onlyOwner public {
        require(state == State.ACTIVE);
        state = State.REFUNDING;
        emit RefundsAllowed();
    }
    function refund(address _address) public {
        require(state == State.REFUNDING);
        uint256 amount = deposits[_address];
        require(amount != 0);
        deposits[_address] = 0;
        _address.transfer(amount);
        emit RefundSuccessful(_address, amount);
    }
}
