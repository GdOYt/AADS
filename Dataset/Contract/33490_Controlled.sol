contract Controlled {
    modifier onlyController { if (msg.sender != controller) throw; _; }
    address public controller;
    function Controlled() { controller = msg.sender;}
    function changeController(address _newController) onlyController {
        controller = _newController;
    }
}
