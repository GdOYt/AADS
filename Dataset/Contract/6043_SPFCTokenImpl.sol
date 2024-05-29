contract SPFCTokenImpl is StandardTokenExt {
    event UpdatedTokenInformation(string newName, string newSymbol);
    string public name;
    string public symbol;
    function releaseTokenTransfer(bool _value) onlyOwner public {
        released = _value;
    }
    function setGlobalTimeVault(uint _globalTimeVaultOpeningTime) onlyOwner public {
        globalTimeVault = _globalTimeVaultOpeningTime;
    }
    function setTokenInformation(string _tokenName, string _tokenSymbol) onlyOwner public {
        name = _tokenName;
        symbol = _tokenSymbol;
        emit UpdatedTokenInformation(name, symbol);
    }
}
