contract ERC223ReceivingContract {
    function tokenFallback(address _from, uint _value, bytes _data) public;
}
