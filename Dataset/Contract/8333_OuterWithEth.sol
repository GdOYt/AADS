contract OuterWithEth {
    Inner1WithEth public myInner1 = new Inner1WithEth();
    function callSomeFunctionViaOuter() public payable {
        myInner1.callSomeFunctionViaInner1.value(msg.value)();
    }
}
