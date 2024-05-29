contract Owned {
  address owner;
  bool frozen = false;
  function Owned() {
    owner = msg.sender;
  }
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  modifier publicMethod() {
    require(!frozen);
    _;
  }
  function drain() onlyOwner {
    owner.transfer(this.balance);
  }
  function freeze() onlyOwner {
    frozen = true;
  }
  function unfreeze() onlyOwner {
    frozen = false;
  }
  function destroy() onlyOwner {
    selfdestruct(owner);
  }
}
