contract EoptCrowdsale is Crowdsale, CappedCrowdsale, AllowanceCrowdsale, DynamicRateCrowdsale, TimedCrowdsale, Ownable {
    constructor(
        uint256 _rate, 
        uint256 _bonusRate, 
        address _wallet, 
        ERC20 _token, 
        uint256 _cap, 
        address _tokenWallet,
        uint256 _openingTime,
        uint256 _closingTime
    )
        Crowdsale(_rate, _wallet, _token)
        CappedCrowdsale(_cap)
        AllowanceCrowdsale(_tokenWallet)
        TimedCrowdsale(_openingTime, _closingTime)
        DynamicRateCrowdsale(_bonusRate)
        public
    {   
    }
    event Purchase(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount,
        uint256 weiRaised,
        uint256 rate,
        uint256 bonusRate,
        uint256 cap
    );
    function _updatePurchasingState(address _beneficiary, uint256 _weiAmount)
        internal
    {
        super._updatePurchasingState(_beneficiary, _weiAmount);
        uint256 tokens = _getTokenAmount(_weiAmount);
        emit Purchase(
            msg.sender,
            _beneficiary,
            _weiAmount,
            tokens,
            weiRaised,
            rate,
            bonusRate,
            cap
        );
    }
    function setRate(uint256 _rate) onlyOwner public {
        require(_rate > 0 && _rate < 1000000);
        rate = _rate;
    }
    function setBonusRate(uint256 _bonusRate) onlyOwner public {
        require(_bonusRate > 0 && _bonusRate < 1000000);
        bonusRate = _bonusRate;
    }
    function setClosingTime(uint256 _closingTime) onlyOwner public {
        require(_closingTime >= block.timestamp);
        require(_closingTime >= openingTime);
        closingTime = _closingTime;
    }
    function setCap(uint256 _cap) onlyOwner public {
        require(_cap > 0 && _cap < 500000000000000000000000);
        cap = _cap;
    }
    function setToken(ERC20 _token) onlyOwner public {
        require(_token != address(0));
        token = _token;
    }
    function setTokenWallet(address _tokenWallet) onlyOwner public {
        require(_tokenWallet != address(0));
        tokenWallet = _tokenWallet;
    }
    function setWallet(address _wallet) onlyOwner public {
        require(_wallet != address(0));
        wallet = _wallet;
    }
}
