contract Controlled {
    modifier onlyController() {
        require(msg.sender == controller);
        _;
    }
    address public controller;
    function Controlled() {
        controller = msg.sender;
    }
    address public newController;
    function changeOwner(address _newController) onlyController {
        newController = _newController;
    }
    function acceptOwnership() {
        if (msg.sender == newController) {
            controller = newController;
        }
    }
}
