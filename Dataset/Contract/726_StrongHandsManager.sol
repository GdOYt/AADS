contract StrongHandsManager {
    event CreateStrongHand(address indexed owner, address indexed strongHand);
    mapping (address => address) public strongHands;
    function getStrong(address _referrer)
        public
        payable
    {
        require(strongHands[msg.sender] == address(0), "you already became a Stronghand");
        strongHands[msg.sender] = new StrongHand(msg.sender, _referrer);
        emit CreateStrongHand(msg.sender, strongHands[msg.sender]);
    }
    function()
        public
        payable
    {
        getStrong(msg.sender);
    }
}
