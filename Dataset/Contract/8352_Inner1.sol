contract Inner1 {
    Inner2 public myInner2 = new Inner2();
    function callSomeFunctionViaInner1() public {
        myInner2.doSomething();
    }
}
