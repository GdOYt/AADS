contract SPFCToken is VersionedToken, SPFCTokenType {
    string public name;
    string public symbol;
    constructor(address _tokenOwner, string _tokenName, string _tokenSymbol, uint _totalSupply, uint _decimals, uint _globalTimeVaultOpeningTime, address _initialImplementation) VersionedToken(_initialImplementation)  public {
        name = _tokenName;
        symbol = _tokenSymbol;
        decimals = _decimals;
        totalSupply = _totalSupply * 10 ** uint(decimals);
        balances[_tokenOwner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
        globalTimeVault = _globalTimeVaultOpeningTime;
        released = false;
    }
}
