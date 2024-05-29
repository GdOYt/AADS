contract PostKYCCrowdsale is Crowdsale, Ownable {
    struct Investment {
        bool isVerified;          
        uint totalWeiInvested;    
        uint pendingTokenAmount;
    }
    uint public pendingWeiAmount = 0;
    mapping(address => Investment) public investments;
    event InvestorVerified(address investor);
    event TokensDelivered(address investor, uint amount);
    event InvestmentWithdrawn(address investor, uint value);
    function verifyInvestors(address[] _investors) public onlyOwner {
        for (uint i = 0; i < _investors.length; ++i) {
            address investor = _investors[i];
            Investment storage investment = investments[investor];
            if (!investment.isVerified) {
                investment.isVerified = true;
                emit InvestorVerified(investor);
                uint pendingTokenAmount = investment.pendingTokenAmount;
                if (pendingTokenAmount > 0) {
                    investment.pendingTokenAmount = 0;
                    _forwardFunds(investment.totalWeiInvested);
                    _deliverTokens(investor, pendingTokenAmount);
                    emit TokensDelivered(investor, pendingTokenAmount);
                }
            }
        }
    }
    function withdrawInvestment() public {
        Investment storage investment = investments[msg.sender];
        require(!investment.isVerified);
        uint totalWeiInvested = investment.totalWeiInvested;
        require(totalWeiInvested > 0);
        investment.totalWeiInvested = 0;
        investment.pendingTokenAmount = 0;
        pendingWeiAmount = pendingWeiAmount.sub(totalWeiInvested);
        msg.sender.transfer(totalWeiInvested);
        emit InvestmentWithdrawn(msg.sender, totalWeiInvested);
        assert(pendingWeiAmount <= address(this).balance);
    }
    function _preValidatePurchase(address _beneficiary, uint _weiAmount) internal {
        require(_beneficiary == msg.sender);
        super._preValidatePurchase(_beneficiary, _weiAmount);
    }
    function _processPurchase(address, uint _tokenAmount) internal {
        Investment storage investment = investments[msg.sender];
        investment.totalWeiInvested = investment.totalWeiInvested.add(msg.value);
        if (investment.isVerified) {
            _deliverTokens(msg.sender, _tokenAmount);
            emit TokensDelivered(msg.sender, _tokenAmount);
        } else {
            investment.pendingTokenAmount = investment.pendingTokenAmount.add(_tokenAmount);
            pendingWeiAmount = pendingWeiAmount.add(msg.value);
        }
    }
    function _forwardFunds() internal {
        if (investments[msg.sender].isVerified) {
            super._forwardFunds();
        }
    }
    function _forwardFunds(uint _weiAmount) internal {
        pendingWeiAmount = pendingWeiAmount.sub(_weiAmount);
        wallet.transfer(_weiAmount);
    }
    function _postValidatePurchase(address, uint _weiAmount) internal {
        super._postValidatePurchase(msg.sender, _weiAmount);
        assert(pendingWeiAmount <= address(this).balance);
    }
}
