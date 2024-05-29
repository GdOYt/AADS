contract Crowdsale {
    using SafeMath for uint256;
    HoldToken public token;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public rate;
    address public wallet;
    uint256 public weiRaised;
    event TokenPurchase(address indexed beneficiary, uint256 indexed value, uint256 indexed amount, uint256 transactionId);
    function Crowdsale(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _rate,
        address _wallet,
        uint256 _initialWeiRaised
    ) public {
        require(_startTime >= now);
        require(_endTime >= _startTime);
        require(_wallet != address(0));
        require(_rate > 0);
        token = new HoldToken(_wallet);
        startTime = _startTime;
        endTime = _endTime;
        rate = _rate;
        wallet = _wallet;
        weiRaised = _initialWeiRaised;
    }
    function hasEnded() public view returns (bool) {
        return now > endTime;
    }
}
