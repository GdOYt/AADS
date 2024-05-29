contract NokuFlatPlan is NokuPricingPlan, Ownable {
    using SafeMath for uint256;
    event LogNokuFlatPlanCreated(
        address indexed caller,
        uint256 indexed paymentInterval,
        uint256 indexed flatFee,
        address nokuMasterToken,
        address tokenBurner
    );
    event LogPaymentIntervalChanged(address indexed caller, uint256 indexed paymentInterval);
    event LogFlatFeeChanged(address indexed caller, uint256 indexed flatFee);
    uint256 public paymentInterval;
    uint256 public nextPaymentTime;
    uint256 public flatFee;
    address public nokuMasterToken;
    address public tokenBurner;
    constructor(
        uint256 _paymentInterval,
        uint256 _flatFee,
        address _nokuMasterToken,
        address _tokenBurner
    )
    public
    {
        require(_paymentInterval != 0, "_paymentInterval is zero");
        require(_flatFee != 0, "_flatFee is zero");
        require(_nokuMasterToken != 0, "_nokuMasterToken is zero");
        require(_tokenBurner != 0, "_tokenBurner is zero");
        paymentInterval = _paymentInterval;
        flatFee = _flatFee;
        nokuMasterToken = _nokuMasterToken;
        tokenBurner = _tokenBurner;
        nextPaymentTime = block.timestamp;
        emit LogNokuFlatPlanCreated(
            msg.sender,
            _paymentInterval,
            _flatFee,
            _nokuMasterToken,
            _tokenBurner
        );
    }
    function setPaymentInterval(uint256 _paymentInterval) public onlyOwner {
        require(_paymentInterval != 0, "_paymentInterval is zero");
        require(_paymentInterval != paymentInterval, "_paymentInterval equal to current one");
        paymentInterval = _paymentInterval;
        emit LogPaymentIntervalChanged(msg.sender, _paymentInterval);
    }
    function setFlatFee(uint256 _flatFee) public onlyOwner {
        require(_flatFee != 0, "_flatFee is zero");
        require(_flatFee != flatFee, "_flatFee equal to current one");
        flatFee = _flatFee;
        emit LogFlatFeeChanged(msg.sender, _flatFee);
    }
    function isValidService(bytes32 _serviceName) public pure returns(bool isValid) {
        return _serviceName != 0;
    }
    function payFee(bytes32 _serviceName, uint256 _multiplier, address _client) public returns(bool paid) {
        require(isValidService(_serviceName), "_serviceName in invalid");
        require(_multiplier != 0, "_multiplier is zero");
        require(_client != 0, "_client is zero");
        require(block.timestamp < nextPaymentTime);
        return true;
    }
    function usageFee(bytes32 _serviceName, uint256 _multiplier) public constant returns(uint fee) {
        require(isValidService(_serviceName), "_serviceName in invalid");
        require(_multiplier != 0, "_multiplier is zero");
        return 0;
    }
    function paySubscription(address _client) public returns(bool paid) {
        require(_client != 0, "_client is zero");
        nextPaymentTime = nextPaymentTime.add(paymentInterval);
        assert(ERC20(nokuMasterToken).transferFrom(_client, tokenBurner, flatFee));
        NokuTokenBurner(tokenBurner).tokenReceived(nokuMasterToken, flatFee);
        return true;
    }
}
