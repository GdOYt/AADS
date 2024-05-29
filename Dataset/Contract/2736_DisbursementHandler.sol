contract DisbursementHandler is DisbursementHandlerI, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;
    struct Disbursement {
        uint256 timestamp;
        uint256 value;
    }
    event Setup(address indexed _beneficiary, uint256 _timestamp, uint256 _value);
    event TokensWithdrawn(address indexed _to, uint256 _value);
    ERC20 public token;
    uint256 public totalAmount;
    mapping(address => Disbursement[]) public disbursements;
    constructor(ERC20 _token) public {
        require(_token != address(0));
        token = _token;
    }
    function setupDisbursement(
        address _beneficiary,
        uint256 _value,
        uint256 _timestamp
    )
        external
        onlyOwner
    {
        require(block.timestamp < _timestamp);
        disbursements[_beneficiary].push(Disbursement(_timestamp, _value));
        totalAmount = totalAmount.add(_value);
        emit Setup(_beneficiary, _timestamp, _value);
    }
    function withdraw(address _beneficiary, uint256 _index)
        external
    {
        Disbursement[] storage beneficiaryDisbursements = disbursements[_beneficiary];
        require(_index < beneficiaryDisbursements.length);
        Disbursement memory disbursement = beneficiaryDisbursements[_index];
        require(disbursement.timestamp < now && disbursement.value > 0);
        delete beneficiaryDisbursements[_index];
        token.safeTransfer(_beneficiary, disbursement.value);
        emit TokensWithdrawn(_beneficiary, disbursement.value);
    }
}
