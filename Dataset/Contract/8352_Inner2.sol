contract Inner2 {
    uint256 someValue;
    event SetValue(uint256 val);
    function doSomething() public {
        someValue = block.timestamp;
        emit SetValue(someValue);
    }
}
