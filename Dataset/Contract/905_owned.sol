contract owned {
    event TransferOwnership(address _owner, address _newOwner);
    event OwnerUpdate(address _prevOwner, address _newOwner);
    event TransferByOwner(address fromAddress, address toAddress, uint tokens);
    event Pause();
    event Unpause();
    address public owner;
    address public newOwner = 0x0;
    bool public paused = false;
    constructor () public {
        owner = msg.sender; 
    }
    modifier onlyOwner {
        require (msg.sender == owner);
        _;
    }
    modifier whenNotPaused() {
        require(!paused);
        _;
    }
    modifier whenPaused() {
        require(paused);
        _;
    }
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != owner);
        newOwner = _newOwner;
        emit TransferOwnership(owner, _newOwner);
    }
    function acceptOwnership() public{
        require(msg.sender == newOwner);
        emit OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = 0x0;
    }
    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Pause();
    }
    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpause();
    }
}
