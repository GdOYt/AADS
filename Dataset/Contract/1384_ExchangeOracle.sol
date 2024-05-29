contract ExchangeOracle is Ownable, Pausable {
    using SafeMath for uint;
    bool public isIrisOracle = true;
    uint public rate = 0;
    uint public minWeiAmount = 1000; 
    event LogRateChanged(uint oldRate, uint newRate, address changer);
    event LogMinWeiAmountChanged(uint oldMinWeiAmount, uint newMinWeiAmount, address changer);
    constructor(uint initialRate) public {
        require(initialRate > 0);
        rate = initialRate;
    }
    function rate() external view whenNotPaused returns(uint) {
        return rate;
    }
    function setRate(uint newRate) external onlyOwner whenNotPaused returns(bool) {
        require(newRate > 0);
        uint oldRate = rate;
        rate = newRate;
        emit LogRateChanged(oldRate, newRate, msg.sender);
        return true;
    }
    function setMinWeiAmount(uint newMinWeiAmount) external onlyOwner whenNotPaused returns(bool) {
        require(newMinWeiAmount > 0);
        require(newMinWeiAmount % 10 == 0); 
        uint oldMinWeiAmount = minWeiAmount;
        minWeiAmount = newMinWeiAmount;
        emit LogMinWeiAmountChanged(oldMinWeiAmount, minWeiAmount, msg.sender);
        return true;
    }
    function convertTokensAmountInWeiAtRate(uint tokensAmount, uint convertRate) external whenNotPaused view returns(uint) {
        uint weiAmount = tokensAmount.mul(minWeiAmount);
        weiAmount = weiAmount.div(convertRate);
        if ((tokensAmount % convertRate) != 0) {
            weiAmount++;
        } 
        return weiAmount;
    }
    function calcWeiForTokensAmount(uint tokensAmount) external view whenNotPaused returns(uint) {
        uint weiAmount = tokensAmount.mul(minWeiAmount);
        weiAmount = weiAmount.div(rate);
        if ((tokensAmount % rate) != 0) {
            weiAmount++;
        } 
        return weiAmount;
    }
}
