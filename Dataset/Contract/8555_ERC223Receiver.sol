contract ERC223Receiver {
    function tokenFallback(address _from, uint _value, bytes _data) public;
}
