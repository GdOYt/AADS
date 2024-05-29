contract SuccessfulERC223Receiver is ERC223Receiver {
    event Invoked(address from, uint value, bytes data);
    function tokenFallback(address _from, uint _value, bytes _data) public {
        emit Invoked(_from, _value, _data);
    }
}
