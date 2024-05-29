contract Inner3WithEth {
    Inner4WithEth public myInner4 = new Inner4WithEth();
    function callSomeFunctionViaInner3() public payable{
        myInner4.doSomething.value(msg.value)();
    }
}
