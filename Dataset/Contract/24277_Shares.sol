contract Shares is Asset, SharesInterface {
    string public name;
    string public symbol;
    uint public decimal;
    uint public creationTime;
    function Shares(string _name, string _symbol, uint _decimal, uint _creationTime) {
        name = _name;
        symbol = _symbol;
        decimal = _decimal;
        creationTime = _creationTime;
    }
    function getName() view returns (string) { return name; }
    function getSymbol() view returns (string) { return symbol; }
    function getDecimals() view returns (uint) { return decimal; }
    function getCreationTime() view returns (uint) { return creationTime; }
    function toSmallestShareUnit(uint quantity) view returns (uint) { return mul(quantity, 10 ** getDecimals()); }
    function toWholeShareUnit(uint quantity) view returns (uint) { return quantity / (10 ** getDecimals()); }
    function transfer(address _to, uint256 _value) public returns (bool) { require(_to == address(this)); }
    function transfer(address _to, uint256 _value, bytes _data) public returns (bool) { require(_to == address(this)); }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) { require(_to == address(this)); }
    function createShares(address recipient, uint shareQuantity) internal {
        totalSupply = add(totalSupply, shareQuantity);
        balances[recipient] = add(balances[recipient], shareQuantity);
        Created(msg.sender, now, shareQuantity);
    }
    function annihilateShares(address recipient, uint shareQuantity) internal {
        totalSupply = sub(totalSupply, shareQuantity);
        balances[recipient] = sub(balances[recipient], shareQuantity);
        Annihilated(msg.sender, now, shareQuantity);
    }
}
