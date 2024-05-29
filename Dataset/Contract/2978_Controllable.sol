contract Controllable {
  address public controller;
  constructor() public {
    controller = msg.sender;
  }
  modifier onlyController() {
    require(msg.sender == controller);
    _;
  }
  function transferControl(address newController) public onlyController {
    if (newController != address(0)) {
      controller = newController;
    }
  }
}
