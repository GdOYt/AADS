contract AbstractSweeper {
    function sweep(address token, uint amount) returns (bool);
    function () { throw; }
    Controller controller;
    function AbstractSweeper(address _controller) {
        controller = Controller(_controller);
    }
    modifier canSweep() {
        if (msg.sender != controller.authorizedCaller() && msg.sender != controller.owner()) throw;
        if (controller.halted()) throw;
        _;
    }
}
