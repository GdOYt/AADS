contract TokenTimelock {
    ERC20Basic token;
    address beneficiary;
    uint releaseTime;
    function TokenTimelock(ERC20Basic _token, address _beneficiary, uint _releaseTime) {
        require(_releaseTime > now);
        token = _token;
        beneficiary = _beneficiary;
        releaseTime = _releaseTime;
    }
    function claim() {
        require(msg.sender == beneficiary);
        require(now >= releaseTime);
        uint amount = token.balanceOf(this);
        require(amount > 0);
        token.transfer(beneficiary, amount);
    }
}
