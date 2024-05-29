contract ERC223Basic {
    uint256 public totalSupply;
    bool public transfersEnabled;
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    function transfer(address to, uint256 value, bytes data) public;
    event Transfer(address indexed from, address indexed to, uint256 value, bytes data);
}
