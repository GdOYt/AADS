contract WaltonTokenLocker {
    address public beneficiary;
    uint256 public releaseTime;
    Token  public token   = Token('0xb7cB1C96dB6B22b0D3d9536E0108d062BD488F74');
    function WaltonTokenLocker() public {
        beneficiary = address('0xa43e4646ee8ebd9AD01BFe87995802D984902e25');
        releaseTime = 1563379200;      
    }
    function release() public {
        uint256 totalTokenBalance;
        uint256 totalEthBalance;
        if (block.timestamp < releaseTime)
            throw;
        totalTokenBalance = token.balanceOf(this);
        totalEthBalance = this.balance;
        if (totalTokenBalance > 0)
            if (!token.transfer(beneficiary, totalTokenBalance))
                throw;
        if (totalEthBalance > 0)
            if (!beneficiary.send(totalEthBalance))
                throw;
    }
    function releaseTimestamp() public constant returns (uint timestamp) {
        return releaseTime;
    }
    function currentTimestamp() public constant returns (uint timestamp) {
        return block.timestamp;
    }
    function secondsRemaining() public constant returns (uint timestamp) {
        return releaseTime - block.timestamp;
    }
    function setReleaseTime(uint256 _releaseTime) public {
        releaseTime = _releaseTime;
    }
}
