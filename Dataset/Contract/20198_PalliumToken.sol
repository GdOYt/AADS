contract PalliumToken is MintableToken, PausableToken, ERC827Token, CanReclaimToken {
    string public constant name = 'PalliumToken';
    string public constant symbol = 'PLMT';
    uint8  public constant decimals = 18;
    function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
        require (totalSupply_ + _amount <= 250 * 10**6 * 10**18);
        return super.mint(_to, _amount);
    }
}
