contract ELTToken is VersionedToken, ELTTokenType {
    string public name;
    string public symbol;
    function ELTToken(address _owner, string _name, string _symbol, uint _totalSupply, uint _decimals, uint _releaseFinalizationDate, address _initialVersion) VersionedToken(_initialVersion) public {
        name = _name;
        symbol = _symbol;
        totalSupply = _totalSupply;
        decimals = _decimals;
        balances[_owner] = _totalSupply;
        releaseFinalizationDate = _releaseFinalizationDate;
        released = false;
    }
}
