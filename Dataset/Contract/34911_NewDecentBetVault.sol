contract NewDecentBetVault is SafeMath {
    bool public isDecentBetVault = false;
    NewDecentBetToken decentBetToken;
    address decentBetMultisig;
    uint256 unlockedAtTime;
    uint256 public constant timeOffset = 47 weeks;
    function NewDecentBetVault(address _decentBetMultisig)   {
        if (_decentBetMultisig == 0x0) revert();
        decentBetToken = NewDecentBetToken(msg.sender);
        decentBetMultisig = _decentBetMultisig;
        isDecentBetVault = true;
        unlockedAtTime = safeAdd(getTime(), timeOffset);
    }
    function unlock() external {
        if (getTime() < unlockedAtTime) revert();
        if (!decentBetToken.transfer(decentBetMultisig, decentBetToken.balanceOf(this))) revert();
    }
    function getTime() internal returns (uint256) {
        return now;
    }
    function() payable {
        revert();
    }
}
