contract ELTTokenImpl is StandardTokenExt {
    event UpdatedTokenInformation(string newName, string newSymbol);
    string public name;
    string public symbol;
    function ELTTokenImpl() public {
    }
    function releaseTokenTransfer(bool _value) onlyOwner public {
        released = _value;
    }
    function setreleaseFinalizationDate(uint _value) onlyOwner public {
        releaseFinalizationDate = _value;
    }
    function setTokenInformation(string _name, string _symbol) onlyOwner public {
        name = _name;
        symbol = _symbol;
        emit UpdatedTokenInformation(name, symbol);
    }
}
