contract ESportsFreezingStorage is Ownable {
    uint64 public releaseTime;
    ESportsToken token;
    function ESportsFreezingStorage(ESportsToken _token, uint64 _releaseTime) {  
        require(_releaseTime > now);
        releaseTime = _releaseTime;
        token = _token;
    }
    function release(address _beneficiary) onlyOwner returns(uint) {
        if (now < releaseTime) return 0;
        uint amount = token.balanceOf(this);
        if (amount == 0)  return 0;
        bool result = token.transfer(_beneficiary, amount);
        if (!result) return 0;
        return amount;
    }
}
