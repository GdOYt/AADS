contract ArezzoGoldCoin is PausableToken, MintableToken, BurnableToken {
    using SafeMath for uint256;
    string public name = "Arezzo Gold Coin";
    string public symbol = "AGC";
    uint public decimals = 18;
    uint256 public constant HARD_CAP = 1000000000* 10**uint256(decimals);
    function mintTimelocked(address _to, uint256 _amount, uint256 _releaseTime)
        onlyOwner canMint returns (TokenTimelock) {
        TokenTimelock timelock = new TokenTimelock(this, _to, _releaseTime);
        mint(timelock, _amount);
        return timelock;
    }
}
