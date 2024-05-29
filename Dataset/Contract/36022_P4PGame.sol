contract P4PGame {
    address public owner;
    address public pool;
    PlayToken playToken;
    bool public active = true;
    event GamePlayed(bytes32 hash, bytes32 boardEndState);
    event GameOver();
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    modifier onlyIfActive() {
        require(active);
        _;
    }
    function P4PGame(address _tokenAddr, address _poolAddr) {
        owner = msg.sender;
        playToken = PlayToken(_tokenAddr);
        pool = _poolAddr;
    }
    function setTokenController(address _controller) onlyOwner {
        playToken.setController(_controller);
    }
    function lockTokenController() onlyOwner {
        playToken.lockController();
    }
    function setPoolContract(address _pool) onlyOwner {
        pool = _pool;
    }
    function addGame(bytes32 hash, bytes32 board) onlyOwner onlyIfActive {
        GamePlayed(hash, board);
    }
    function distributeTokens(address[] receivers, uint16[] amounts) onlyOwner onlyIfActive {
        require(receivers.length == amounts.length);
        var totalAmount = distributeTokensImpl(receivers, amounts);
        payoutPool(totalAmount);
    }
    function shutdown() onlyOwner {
        active = false;
        GameOver();
    }
    function getTokenAddress() constant returns(address) {
        return address(playToken);
    }
    function distributeTokensImpl(address[] receivers, uint16[] amounts) internal returns(uint256) {
        uint256 totalAmount = 0;
        for (uint i = 0; i < receivers.length; i++) {
            playToken.mint(receivers[i], uint256(amounts[i]) * 1e18);
            totalAmount += amounts[i];
        }
        return totalAmount;
    }
    function payoutPool(uint256 amount) internal {
        require(pool != 0);
        playToken.mint(pool, amount * 1e18);
    }
}
