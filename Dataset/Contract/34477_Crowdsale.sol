contract Crowdsale {
    using SafeMath for uint;
    MintableToken public token;
    uint32 public startTime;
    uint32 public endTime;
    address public wallet;
    uint public rate;
    uint public weiRaised;
    uint public soldTokens;
    uint public hardCap;
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint value, uint amount);
    function Crowdsale(uint32 _startTime, uint32 _endTime, uint _rate, uint _hardCap, address _wallet, address _token) {
        require(_startTime >= now);
        require(_endTime >= _startTime);
        require(_rate > 0);
        require(_wallet != 0x0);
        require(_hardCap > _rate);
        token = MintableToken(_token);
        startTime = _startTime;
        endTime = _endTime;
        rate = _rate;
        hardCap = _hardCap;
        wallet = _wallet;
    }
    function getRate() internal constant returns (uint) {
        return rate;
    }
    function() payable {
        buyTokens(msg.sender, msg.value);
    }
    function buyTokens(address beneficiary, uint amountWei) internal {
        require(beneficiary != 0x0);
        uint totalSupply = token.totalSupply();
        uint actualRate = getRate();
        require(validPurchase(amountWei, actualRate, totalSupply));
        uint tokens = amountWei.mul(actualRate);
        if (msg.value == 0) {  
            require(tokens.add(totalSupply) <= hardCap);
        }
        uint change = 0;
        if (tokens.add(totalSupply) > hardCap) {
            uint maxTokens = hardCap.sub(totalSupply);
            uint realAmount = maxTokens.div(actualRate);
            tokens = realAmount.mul(actualRate);
            change = amountWei.sub(realAmount);
            amountWei = realAmount;
        }
        postBuyTokens(beneficiary, tokens);
        weiRaised = weiRaised.add(amountWei);
        soldTokens = soldTokens.add(tokens);
        token.mint(beneficiary, tokens);
        TokenPurchase(msg.sender, beneficiary, amountWei, tokens);
        if (msg.value != 0) {
            if (change != 0) {
                msg.sender.transfer(change);
            }
            forwardFunds(amountWei);
        }
    }
    function forwardFunds(uint amountWei) internal {
        wallet.transfer(amountWei);
    }
    function postBuyTokens(address _beneficiary, uint _tokens) internal {
    }
    function validPurchase(uint _amountWei, uint _actualRate, uint _totalSupply) internal constant returns (bool) {
        bool withinPeriod = now >= startTime && now <= endTime;
        bool nonZeroPurchase = _amountWei != 0;
        bool hardCapNotReached = _totalSupply <= hardCap.sub(_actualRate);
        return withinPeriod && nonZeroPurchase && hardCapNotReached;
    }
    function hasEnded() public constant returns (bool) {
        return now > endTime || token.totalSupply() > hardCap.sub(getRate());
    }
    function hasStarted() public constant returns (bool) {
        return now >= startTime;
    }
}
