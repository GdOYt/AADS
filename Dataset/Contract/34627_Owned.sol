contract Owned {
    address public owner;
    address public newOwner;
    address public oracle;
    address public btcOracle;
    function Owned() payable {
        owner = msg.sender;
    }
    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }
    modifier onlyOwnerOrOracle {
        require(owner == msg.sender || oracle == msg.sender);
        _;
    }
    modifier onlyOwnerOrBtcOracle {
        require(owner == msg.sender || btcOracle == msg.sender);
        _;
    }
    function changeOwner(address _owner) onlyOwner external {
        require(_owner != 0);
        newOwner = _owner;
    }
    function confirmOwner() external {
        require(newOwner == msg.sender);
        owner = newOwner;
        delete newOwner;
    }
    function changeOracle(address _oracle) onlyOwner external {
        require(_oracle != 0);
        oracle = _oracle;
    }
    function changeBtcOracle(address _btcOracle) onlyOwner external {
        require(_btcOracle != 0);
        btcOracle = _btcOracle;
    }
}
