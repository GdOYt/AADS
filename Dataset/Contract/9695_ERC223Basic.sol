contract ERC223Basic is ERC20Basic {
    function transfer(address _to, uint _value, bytes _data) public returns (bool);
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _value, bytes _data);
}
