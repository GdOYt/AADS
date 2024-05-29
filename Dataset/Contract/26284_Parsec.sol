contract Parsec is Delegatable, DelegateProxy {
  function () public {
    delegatedFwd(delegation, msg.data);
  }
  function initialize(address _controller, uint256 _cap) public {
    require(owner == 0);
    owner = msg.sender;
    delegation = _controller;
    delegatedFwd(_controller, msg.data);
  }
}
