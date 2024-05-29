contract Delegate {
  address public owner;
  function Delegate(address _owner) {
    owner = _owner;
  }
  function pwn() {
    owner = msg.sender;
  }
}
