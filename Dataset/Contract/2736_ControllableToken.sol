contract ControllableToken is Ownable, StandardToken {
    TokenControllerI public controller;
    modifier isAllowed(address _from, address _to) {
        require(controller.transferAllowed(_from, _to));
        _;
    }
    function setController(TokenControllerI _controller) onlyOwner public {
        require(_controller != address(0));
        controller = _controller;
    }
    function transfer(address _to, uint256 _value) 
        isAllowed(msg.sender, _to)
        public
        returns (bool)
    {
        return super.transfer(_to, _value);
    }
    function transferFrom(address _from, address _to, uint256 _value)
        isAllowed(_from, _to) 
        public 
        returns (bool)
    {
        return super.transferFrom(_from, _to, _value);
    }
}
