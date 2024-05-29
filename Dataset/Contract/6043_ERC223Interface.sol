contract ERC223Interface {
    uint public totalSupply;
    function transfer(address to, uint value, bytes data) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint value, bytes data);
}
