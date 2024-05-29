contract BaseContract {
    bool public TokensAreFrozen = true;
    address public owner;
    constructor () public {
        owner = msg.sender;
    }
    modifier onlyByOwner() {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) external onlyByOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}
