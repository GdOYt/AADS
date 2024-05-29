contract Manager is IManager {
    IController public controller;
    modifier onlyController() {
        require(msg.sender == address(controller));
        _;
    }
    modifier onlyControllerOwner() {
        require(msg.sender == controller.owner());
        _;
    }
    modifier whenSystemNotPaused() {
        require(!controller.paused());
        _;
    }
    modifier whenSystemPaused() {
        require(controller.paused());
        _;
    }
    function Manager(address _controller) public {
        controller = IController(_controller);
    }
    function setController(address _controller) external onlyController {
        controller = IController(_controller);
        SetController(_controller);
    }
}
