contract ERC677 is ERC20 {
    function transferAndCall(address to, uint value, bytes data) public returns (bool ok);
    event TransferAndCall(address indexed from, address indexed to, uint value, bytes data);
}
