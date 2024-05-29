contract BonusableCrowdsale is Consts, Crowdsale {
    function buyTokens(address beneficiary) public payable {
        require(beneficiary != address(0));
        require(validPurchase());
        uint256 weiAmount = msg.value;
        uint256 bonusRate = getBonusRate(weiAmount);
        uint256 tokens = weiAmount.mul(bonusRate).div(1 ether);
        weiRaised = weiRaised.add(weiAmount);
        token.mint(beneficiary, tokens);
        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
        forwardFunds();
    }
    function getBonusRate(uint256 weiAmount) internal view returns (uint256) {
        uint256 bonusRate = rate;
        uint[4] memory weiRaisedStartsBoundaries = [uint(0),uint(0),uint(0),uint(0)];
        uint[4] memory weiRaisedEndsBoundaries = [uint(20000000000000000000000),uint(20000000000000000000000),uint(20000000000000000000000),uint(20000000000000000000000)];
        uint64[4] memory timeStartsBoundaries = [uint64(1531087260),uint64(1532383140),uint64(1534197540),uint64(1536011940)];
        uint64[4] memory timeEndsBoundaries = [uint64(1532383140),uint64(1534197540),uint64(1536011940),uint64(1537221540)];
        uint[4] memory weiRaisedAndTimeRates = [uint(400),uint(300),uint(200),uint(100)];
        for (uint i = 0; i < 4; i++) {
            bool weiRaisedInBound = (weiRaisedStartsBoundaries[i] <= weiRaised) && (weiRaised < weiRaisedEndsBoundaries[i]);
            bool timeInBound = (timeStartsBoundaries[i] <= now) && (now < timeEndsBoundaries[i]);
            if (weiRaisedInBound && timeInBound) {
                bonusRate += bonusRate * weiRaisedAndTimeRates[i] / 1000;
            }
        }
        uint[2] memory weiAmountBoundaries = [uint(20000000000000000000),uint(10000000000000000000)];
        uint[2] memory weiAmountRates = [uint(0),uint(50)];
        for (uint j = 0; j < 2; j++) {
            if (weiAmount >= weiAmountBoundaries[j]) {
                bonusRate += bonusRate * weiAmountRates[j] / 1000;
                break;
            }
        }
        return bonusRate;
    }
}
