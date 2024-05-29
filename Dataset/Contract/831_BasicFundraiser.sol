contract BasicFundraiser is HasOwner, AbstractFundraiser {
    using SafeMath for uint256;
    uint8 constant DECIMALS = 18;   
    uint256 constant DECIMALS_FACTOR = 10 ** uint256(DECIMALS);
    uint256 public startTime;
    uint256 public endTime;
    address public beneficiary;
    uint256 public conversionRate;
    uint256 public totalRaised;
    event ConversionRateChanged(uint _conversionRate);
    function initializeBasicFundraiser(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _conversionRate,
        address _beneficiary
    )
        internal
    {
        require(_endTime >= _startTime);
        require(_conversionRate > 0);
        require(_beneficiary != address(0));
        startTime = _startTime;
        endTime = _endTime;
        conversionRate = _conversionRate;
        beneficiary = _beneficiary;
    }
    function setConversionRate(uint256 _conversionRate) public onlyOwner {
        require(_conversionRate > 0);
        conversionRate = _conversionRate;
        emit ConversionRateChanged(_conversionRate);
    }
    function setBeneficiary(address _beneficiary) public onlyOwner {
        require(_beneficiary != address(0));
        beneficiary = _beneficiary;
    }
    function receiveFunds(address _address, uint256 _amount) internal {
        validateTransaction();
        uint256 tokens = calculateTokens(_amount);
        require(tokens > 0);
        totalRaised = totalRaised.plus(_amount);
        handleTokens(_address, tokens);
        handleFunds(_address, _amount);
        emit FundsReceived(_address, msg.value, tokens);
    }
    function getConversionRate() public view returns (uint256) {
        return conversionRate;
    }
    function calculateTokens(uint256 _amount) internal view returns(uint256 tokens) {
        tokens = _amount.mul(getConversionRate());
    }
    function validateTransaction() internal view {
        require(msg.value != 0);
        require(now >= startTime && now < endTime);
    }
    function hasEnded() public view returns (bool) {
        return now >= endTime;
    }
}
