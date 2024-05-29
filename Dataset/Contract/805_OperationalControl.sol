contract OperationalControl {
    event ContractUpgrade(address newContract);
    address public gameManagerPrimary;
    address public gameManagerSecondary;
    address public bankManager;
    bool public paused = false;
    modifier onlyGameManager() {
        require(msg.sender == gameManagerPrimary || msg.sender == gameManagerSecondary);
        _;
    }
    modifier onlyBanker() {
        require(msg.sender == bankManager);
        _;
    }
    modifier anyOperator() {
        require(
            msg.sender == gameManagerPrimary ||
            msg.sender == gameManagerSecondary ||
            msg.sender == bankManager
        );
        _;
    }
    function setPrimaryGameManager(address _newGM) external onlyGameManager {
        require(_newGM != address(0));
        gameManagerPrimary = _newGM;
    }
    function setSecondaryGameManager(address _newGM) external onlyGameManager {
        require(_newGM != address(0));
        gameManagerSecondary = _newGM;
    }
    function setBanker(address _newBK) external onlyBanker {
        require(_newBK != address(0));
        bankManager = _newBK;
    }
    modifier whenNotPaused() {
        require(!paused);
        _;
    }
    modifier whenPaused {
        require(paused);
        _;
    }
    function pause() external onlyGameManager whenNotPaused {
        paused = true;
    }
    function unpause() public onlyGameManager whenPaused {
        paused = false;
    }
}
