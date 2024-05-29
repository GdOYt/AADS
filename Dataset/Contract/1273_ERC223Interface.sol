contract ERC223Interface is ERC20Interface {
    function transfer(address _to, uint256 _value, bytes _data) public returns (bool ok);
    event Transfer(address indexed _from, address indexed _to, uint256 _value, bytes indexed _data);
}
