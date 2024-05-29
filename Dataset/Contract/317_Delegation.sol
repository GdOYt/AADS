contract Delegation {
  address public owner;
  Delegate delegate;
  function Delegation(address _delegateAddress) {
    delegate = Delegate(_delegateAddress);
    owner = msg.sender;
  }
  function() {
    if(delegate.delegatecall(msg.data)) {
      this;
    }
  }
}
