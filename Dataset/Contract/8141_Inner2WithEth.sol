contract Inner2WithEth {
    Inner3WithEth public myInner3 = new Inner3WithEth();
    function callSomeFunctionViaInner2() public payable{
        myInner3.callSomeFunctionViaInner3.value(msg.value)();
    }
}
