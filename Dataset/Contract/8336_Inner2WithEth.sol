contract Inner2WithEth {
    uint256 someValue;
    event SetValue(uint256 val);
    function doSomething() public payable {
        someValue = block.timestamp;
        emit SetValue(someValue);
        msg.sender.transfer(msg.value);
    }
}
