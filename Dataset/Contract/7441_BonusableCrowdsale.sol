contract BonusableCrowdsale is Consts, Crowdsale {
    function buyTokens(address beneficiary) public payable {
        require(beneficiary != address(0));
        require(validPurchase());
        uint256 weiAmount = msg.value;
        uint256 bonusRate = getBonusRate(weiAmount);
        uint256 tokens = weiAmount.mul(bonusRate).div(1 ether);
        weiRaised = weiRaised.add(weiAmount);
        token.mint(beneficiary, tokens);
        emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
        forwardFunds();
    }
    function getBonusRate(uint256 weiAmount) internal view returns (uint256) {
        uint256 bonusRate = rate;
        uint[5] memory weiRaisedStartsBoundaries = [uint(0),uint(4583333333333333333333),uint(8333333333333333333333),uint(16666666666666666666667),uint(25000000000000000000000)];
        uint[5] memory weiRaisedEndsBoundaries = [uint(4583333333333333333333),uint(8333333333333333333333),uint(16666666666666666666667),uint(25000000000000000000000),uint(33333333333333333333333)];
        uint64[5] memory timeStartsBoundaries = [uint64(1530417600),uint64(1530417600),uint64(1530417600),uint64(1530417600),uint64(1530417600)];
        uint64[5] memory timeEndsBoundaries = [uint64(1543640395),uint64(1543640395),uint64(1543640395),uint64(1543640395),uint64(1543640395)];
        uint[5] memory weiRaisedAndTimeRates = [uint(300),uint(200),uint(150),uint(100),uint(50)];
        for (uint i = 0; i < 5; i++) {
            bool weiRaisedInBound = (weiRaisedStartsBoundaries[i] <= weiRaised) && (weiRaised < weiRaisedEndsBoundaries[i]);
            bool timeInBound = (timeStartsBoundaries[i] <= now) && (now < timeEndsBoundaries[i]);
            if (weiRaisedInBound && timeInBound) {
                bonusRate += bonusRate * weiRaisedAndTimeRates[i] / 1000;
            }
        }
        return bonusRate;
    }
}
