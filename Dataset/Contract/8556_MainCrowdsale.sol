contract MainCrowdsale is Consts, FinalizableCrowdsale {
    function hasStarted() public constant returns (bool) {
        return now >= startTime;
    }
    function finalization() internal {
        super.finalization();
        if (PAUSED) {
            MainToken(token).unpause();
        }
        if (!CONTINUE_MINTING) {
            token.finishMinting();
        }
        token.transferOwnership(TARGET_USER);
    }
    function buyTokens(address beneficiary) public payable {
        require(beneficiary != address(0));
        require(validPurchase());
        uint256 weiAmount = msg.value;
        uint256 tokens = weiAmount.mul(rate).div(1 ether);
        weiRaised = weiRaised.add(weiAmount);
        token.mint(beneficiary, tokens);
        emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
        forwardFunds();
    }
}
