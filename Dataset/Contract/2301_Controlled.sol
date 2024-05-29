contract Controlled {
    modifier onlyController { require(msg.sender == controller); _; }
    address public controller;
    function Controlled() public { controller = msg.sender;}
    function changeController(address _newController) public onlyController {
        controller = _newController;
    }
}
