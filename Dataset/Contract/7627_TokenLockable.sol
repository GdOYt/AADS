contract TokenLockable is RpSafeMath, Ownable {
    mapping(address => uint256) public lockedTokens;
    function lockTokens(address token, uint256 amount) internal {
        lockedTokens[token] = safeAdd(lockedTokens[token], amount);
    }
    function unlockTokens(address token, uint256 amount) internal {
        lockedTokens[token] = safeSubtract(lockedTokens[token], amount);
    }
    function withdrawTokens(Token token, address to, uint256 amount) public onlyOwner returns (bool) {
        require(safeSubtract(token.balanceOf(this), lockedTokens[token]) >= amount);
        require(to != address(0));
        return token.transfer(to, amount);
    }
}
