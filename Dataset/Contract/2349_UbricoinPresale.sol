contract UbricoinPresale {
    enum Phase {
        Created,
        Running,
        Paused,
        Migrating,
        Migrated
    }
    Phase public currentPhase = Phase.Created;
    uint public totalSupply = 0;  
    address public tokenManager=0xAC762012330350DDd97Cc64B133536F8E32193a8;
    address public escrow=0x28970854Bfa61C0d6fE56Cc9daAAe5271CEaEC09;
    address public crowdsaleManager=0x9888375f4663891770DaaaF9286d97d44FeFC82E;
    mapping (address => uint256) private balance;
    modifier onlyTokenManager()     { if(msg.sender != tokenManager) revert(); _; }
    modifier onlyCrowdsaleManager() { if(msg.sender != crowdsaleManager) revert(); _; }
    event LogBuy(address indexed owner, uint256 value);
    event LogBurn(address indexed owner, uint256 value);
    event LogPhaseSwitch(Phase newPhase);
    function burnTokens(address _owner) public
        onlyCrowdsaleManager
    {
        if(currentPhase != Phase.Migrating) revert();
        uint256 tokens = balance[_owner];
        if(tokens == 0) revert();
        balance[_owner] = 0;
        emit LogBurn(_owner, tokens);
    }
    function setPresalePhase(Phase _nextPhase) public
        onlyTokenManager
    {
        bool canSwitchPhase
            =  (currentPhase == Phase.Created && _nextPhase == Phase.Running)
            || (currentPhase == Phase.Running && _nextPhase == Phase.Paused)
            || ((currentPhase == Phase.Running || currentPhase == Phase.Paused)
                && _nextPhase == Phase.Migrating
                && crowdsaleManager != 0x0)
            || (currentPhase == Phase.Paused && _nextPhase == Phase.Running)
            || (currentPhase == Phase.Migrating && _nextPhase == Phase.Migrated
                && totalSupply == 0);
        if(!canSwitchPhase) revert();
        currentPhase = _nextPhase;
        emit LogPhaseSwitch(_nextPhase); 
    }
    function withdrawEther() public
        onlyTokenManager
    {
        if(address(this).balance > 0) {
            if(!escrow.send(address(this).balance)) revert();
        }
    }
    function setCrowdsaleManager(address _mgr) public
        onlyTokenManager
    {
        if(currentPhase == Phase.Migrating) revert();
        crowdsaleManager = _mgr;
    }
}
