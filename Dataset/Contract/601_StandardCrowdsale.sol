contract StandardCrowdsale {
    using SafeMath for uint256;
    StandardToken public token; 
    uint256 public icoStartTime;
    uint256 public presaleStartTime;
    uint256 public presaleEndTime;
    address public wallet;
    uint256 public icoRate;
    uint256 public tier1Rate;
    uint256 public tier2Rate;
    uint256 public tier3Rate;
    uint256 public tier4Rate;
    uint256 public weiRaised;
    event TokenPurchase(address indexed purchaser, uint256 value, uint256 amount);
    function StandardCrowdsale(
        uint256 _icoStartTime,  
        uint256 _presaleStartTime,
        uint256 _presaleEndTime,
        uint256 _icoRate, 
        uint256 _tier1Rate,
        uint256 _tier2Rate,
        uint256 _tier3Rate,
        uint256 _tier4Rate,
        address _wallet) {
        require(_icoStartTime >= now);
        require(_icoRate > 0);
        require(_wallet != 0x0);
        icoStartTime = _icoStartTime;
        presaleStartTime = _presaleStartTime;
        presaleEndTime = _presaleEndTime;
        tier1Rate = _tier1Rate;
        tier2Rate = _tier2Rate;
        tier3Rate = _tier3Rate;
        tier4Rate = _tier4Rate;
        icoRate = _icoRate;
        wallet = _wallet;
        token = createTokenContract(); 
    }
    function createTokenContract() internal returns(StandardToken) {
        return new StandardToken();
    }
    function () payable {
        buyTokens();
    }
    function buyTokens() public payable {
        require(validPurchase()); 
        uint256 weiAmount = msg.value;
        uint256 tokens = weiAmount.mul(icoRate);
        if ((now >= presaleStartTime && now < presaleEndTime) && weiRaised.add(weiAmount) <= 600 ether) {        
            if (weiAmount < 2 ether) 
                tokens = weiAmount.mul(tier1Rate);
            if (weiAmount >= 2 ether && weiAmount < 5 ether) 
                tokens = weiAmount.mul(tier2Rate);
            if (weiAmount >= 5 ether && weiAmount < 10 ether)
                tokens = weiAmount.mul(tier3Rate);
            if (weiAmount >= 10 ether)
                tokens = weiAmount.mul(tier4Rate);
        } 
        weiRaised = weiRaised.add(weiAmount);
        require(token.transfer(msg.sender, tokens));
        TokenPurchase(msg.sender, weiAmount, tokens);
        wallet.transfer(msg.value);
    }
    function validPurchase() internal returns(bool) {
        bool withinPresalePeriod = now >= presaleStartTime;
        bool withinICOPeriod = now >= icoStartTime;
        bool nonZeroPurchase = msg.value != 0;
        return (withinPresalePeriod && nonZeroPurchase && weiRaised <= 600 ether) || (withinICOPeriod && nonZeroPurchase && weiRaised <= 3000 ether);
    }
}
