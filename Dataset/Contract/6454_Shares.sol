contract Shares is SharesInterface, Asset {
    bytes32 public name;
    bytes8 public symbol;
    uint public decimal;
    uint public creationTime;
    function Shares(bytes32 _name, bytes8 _symbol, uint _decimal, uint _creationTime) {
        name = _name;
        symbol = _symbol;
        decimal = _decimal;
        creationTime = _creationTime;
    }
    function transfer(address _to, uint _value)
        public
        returns (bool success)
    {
        require(balances[msg.sender] >= _value);  
        require(balances[_to] + _value >= balances[_to]);
        balances[msg.sender] = sub(balances[msg.sender], _value);
        balances[_to] = add(balances[_to], _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    function getName() view returns (bytes32) { return name; }
    function getSymbol() view returns (bytes8) { return symbol; }
    function getDecimals() view returns (uint) { return decimal; }
    function getCreationTime() view returns (uint) { return creationTime; }
    function toSmallestShareUnit(uint quantity) view returns (uint) { return mul(quantity, 10 ** getDecimals()); }
    function toWholeShareUnit(uint quantity) view returns (uint) { return quantity / (10 ** getDecimals()); }
    function createShares(address recipient, uint shareQuantity) internal {
        _totalSupply = add(_totalSupply, shareQuantity);
        balances[recipient] = add(balances[recipient], shareQuantity);
        emit Created(msg.sender, now, shareQuantity);
        emit Transfer(address(0), recipient, shareQuantity);
    }
    function annihilateShares(address recipient, uint shareQuantity) internal {
        _totalSupply = sub(_totalSupply, shareQuantity);
        balances[recipient] = sub(balances[recipient], shareQuantity);
        emit Annihilated(msg.sender, now, shareQuantity);
        emit Transfer(recipient, address(0), shareQuantity);
    }
}
