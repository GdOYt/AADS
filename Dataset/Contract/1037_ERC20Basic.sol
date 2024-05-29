contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) public view returns (uint);
    function transfer(address to, uint value) public returns (bool ok);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
}
