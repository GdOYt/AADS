contract Inner1WithEth {
    Inner2WithEth public myInner2 = new Inner2WithEth();
    function callSomeFunctionViaInner1() public payable{
        myInner2.doSomething.value(msg.value)();
    }
}
