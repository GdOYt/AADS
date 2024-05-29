contract TelcoinSaleKYCEscrow {
    using SafeMath for uint256;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ValuePlaced(address indexed purchaser, address indexed beneficiary, uint256 amount);
    event Approved(address indexed participant);
    event Rejected(address indexed participant);
    event Closed();
    address public owner;
    TelcoinSale public sale;
    bool public closed = false;
    mapping(address => uint256) public deposited;
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    modifier escrowOpen() {
        require(!closed);
        _;
    }
    function TelcoinSaleKYCEscrow(TelcoinSale _sale) public {
        require(_sale != address(0));
        owner = msg.sender;
        sale = _sale;
    }
    function () public payable {
        placeValue(msg.sender);
    }
    function approve(address _participant) onlyOwner public {
        uint256 weiAmount = deposited[_participant];
        require(weiAmount > 0);
        deposited[_participant] = 0;
        Approved(_participant);
        sale.buyTokens.value(weiAmount)(_participant);
    }
    function approveMany(address[] _participants) onlyOwner public {
        for (uint256 i = 0; i < _participants.length; i++) {
            approve(_participants[i]);
        }
    }
    function close() onlyOwner public {
        require(!closed);
        closed = true;
        Closed();
    }
    function placeValue(address _beneficiary) escrowOpen public payable {
        require(_beneficiary != address(0));
        uint256 weiAmount = msg.value;
        require(weiAmount > 0);
        uint256 newDeposited = deposited[_beneficiary].add(weiAmount);
        deposited[_beneficiary] = newDeposited;
        ValuePlaced(
            msg.sender,
            _beneficiary,
            weiAmount
        );
    }
    function reject(address _participant) onlyOwner public {
        uint256 weiAmount = deposited[_participant];
        require(weiAmount > 0);
        deposited[_participant] = 0;
        Rejected(_participant);
        require(_participant.call.value(weiAmount)());
    }
    function rejectMany(address[] _participants) onlyOwner public {
        for (uint256 i = 0; i < _participants.length; i++) {
            reject(_participants[i]);
        }
    }
    function transferOwnership(address _to) onlyOwner public {
        require(_to != address(0));
        OwnershipTransferred(owner, _to);
        owner = _to;
    }
}
