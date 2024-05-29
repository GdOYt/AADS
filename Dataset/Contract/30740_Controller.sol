contract Controller is AbstractSweeperList {
    address public owner;
    address public authorizedCaller;
    address public destination;
    bool public halted;
    event LogNewWallet(address receiver);
    event LogSweep(address indexed from, address indexed to, address indexed token, uint amount);
    modifier onlyOwner() {
        if (msg.sender != owner) throw; 
        _;
    }
    modifier onlyAuthorizedCaller() {
        if (msg.sender != authorizedCaller) throw; 
        _;
    }
    modifier onlyAdmins() {
        if (msg.sender != authorizedCaller && msg.sender != owner) throw; 
        _;
    }
    function Controller() 
    {
        owner = msg.sender;
        destination = msg.sender;
        authorizedCaller = msg.sender;
    }
    function changeAuthorizedCaller(address _newCaller) onlyOwner {
        authorizedCaller = _newCaller;
    }
    function changeDestination(address _dest) onlyOwner {
        destination = _dest;
    }
    function changeOwner(address _owner) onlyOwner {
        owner = _owner;
    }
    function makeWallet() onlyAdmins returns (address wallet)  {
        wallet = address(new UserWallet(this));
        LogNewWallet(wallet);
    }
    function halt() onlyAdmins {
        halted = true;
    }
    function start() onlyOwner {
        halted = false;
    }
    address public defaultSweeper = address(new DefaultSweeper(this));
    mapping (address => address) sweepers;
    function addSweeper(address _token, address _sweeper) onlyOwner {
        sweepers[_token] = _sweeper;
    }
    function sweeperOf(address _token) returns (address) {
        address sweeper = sweepers[_token];
        if (sweeper == 0) sweeper = defaultSweeper;
        return sweeper;
    }
    function logSweep(address from, address to, address token, uint amount) {
        LogSweep(from, to, token, amount);
    }
}
