contract ERC223Receiver {
    function tokenFallback(address _fromm, uint256 _value, bytes _data) public pure;
}
