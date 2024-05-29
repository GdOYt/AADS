contract ERC223 is ERC20 {
    function transfer(address to, uint256 value, bytes data) public returns(bool);
}
