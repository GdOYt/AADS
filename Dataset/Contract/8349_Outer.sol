contract Outer {
    Inner1 public myInner1 = new Inner1();
    function callSomeFunctionViaOuter() public {
        myInner1.callSomeFunctionViaInner1();
    }
}
