contract TinyProxy {
  address public receiver;
  uint public gasBudget;
  function TinyProxy(address toAddr, uint proxyGas) public {
    receiver = toAddr;
    gasBudget = proxyGas;
  }
  function () payable public { }
  event FundsReleased(address to, uint amount);
  function release() public {
    uint balance = address(this).balance;
    FundsReleased(receiver, balance);
    if(gasBudget > 0){
      receiver.call.gas(gasBudget).value(balance);
    } else {
      receiver.transfer(balance);
    }
  }
}
