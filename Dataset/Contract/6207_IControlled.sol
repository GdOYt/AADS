contract IControlled {
    function getController() public view returns (IController);
    function setController(IController _controller) public returns(bool);
}
