contract TokenReceiver {
    function onTokenTransfer(address _from, uint256 _value, bytes _data) public;
}
