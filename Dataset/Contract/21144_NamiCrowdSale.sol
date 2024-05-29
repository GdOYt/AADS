contract NamiCrowdSale {
    using SafeMath for uint256;
    function NamiCrowdSale(address _escrow, address _namiMultiSigWallet, address _namiPresale) public {
        require(_namiMultiSigWallet != 0x0);
        escrow = _escrow;
        namiMultiSigWallet = _namiMultiSigWallet;
        namiPresale = _namiPresale;
    }
    string public name = "Nami ICO";
    string public  symbol = "NAC";
    uint   public decimals = 18;
    bool public TRANSFERABLE = false;  
    uint public constant TOKEN_SUPPLY_LIMIT = 1000000000 * (1 ether / 1 wei);
    uint public binary = 0;
    enum Phase {
        Created,
        Running,
        Paused,
        Migrating,
        Migrated
    }
    Phase public currentPhase = Phase.Created;
    uint public totalSupply = 0;  
    address public escrow;
    address public namiMultiSigWallet;
    address public namiPresale;
    address public crowdsaleManager;
    address public binaryAddress;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    modifier onlyCrowdsaleManager() {
        require(msg.sender == crowdsaleManager); 
        _; 
    }
    modifier onlyEscrow() {
        require(msg.sender == escrow);
        _;
    }
    modifier onlyTranferable() {
        require(TRANSFERABLE);
        _;
    }
    modifier onlyNamiMultisig() {
        require(msg.sender == namiMultiSigWallet);
        _;
    }
    event LogBuy(address indexed owner, uint value);
    event LogBurn(address indexed owner, uint value);
    event LogPhaseSwitch(Phase newPhase);
    event LogMigrate(address _from, address _to, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 value);
    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0);
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        Transfer(_from, _to, _value);
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }
    function transferForTeam(address _to, uint256 _value) public
        onlyEscrow
    {
        _transfer(msg.sender, _to, _value);
    }
    function transfer(address _to, uint256 _value) public
        onlyTranferable
    {
        _transfer(msg.sender, _to, _value);
    }
    function transferFrom(address _from, address _to, uint256 _value) 
        public
        onlyTranferable
        returns (bool success)
    {
        require(_value <= allowance[_from][msg.sender]);      
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }
    function approve(address _spender, uint256 _value) public
        onlyTranferable
        returns (bool success) 
    {
        allowance[msg.sender][_spender] = _value;
        return true;
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        onlyTranferable
        returns (bool success) 
    {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }
    function changeTransferable () public
        onlyEscrow
    {
        TRANSFERABLE = !TRANSFERABLE;
    }
    function changeEscrow(address _escrow) public
        onlyNamiMultisig
    {
        require(_escrow != 0x0);
        escrow = _escrow;
    }
    function changeBinary(uint _binary)
        public
        onlyEscrow
    {
        binary = _binary;
    }
    function changeBinaryAddress(address _binaryAddress)
        public
        onlyEscrow
    {
        require(_binaryAddress != 0x0);
        binaryAddress = _binaryAddress;
    }
    function getPrice() public view returns (uint price) {
        if (now < 1517443200) {
            return 3450;
        } else if (1517443200 < now && now <= 1518048000) {
            return 2400;
        } else if (1518048000 < now && now <= 1518652800) {
            return 2300;
        } else if (1518652800 < now && now <= 1519257600) {
            return 2200;
        } else if (1519257600 < now && now <= 1519862400) {
            return 2100;
        } else if (1519862400 < now && now <= 1520467200) {
            return 2000;
        } else if (1520467200 < now && now <= 1521072000) {
            return 1900;
        } else if (1521072000 < now && now <= 1521676800) {
            return 1800;
        } else if (1521676800 < now && now <= 1522281600) {
            return 1700;
        } else {
            return binary;
        }
    }
    function() payable public {
        buy(msg.sender);
    }
    function buy(address _buyer) payable public {
        require(currentPhase == Phase.Running);
        require(now <= 1522281600 || msg.sender == binaryAddress);
        require(msg.value != 0);
        uint newTokens = msg.value * getPrice();
        require (totalSupply + newTokens < TOKEN_SUPPLY_LIMIT);
        balanceOf[_buyer] = balanceOf[_buyer].add(newTokens);
        totalSupply = totalSupply.add(newTokens);
        LogBuy(_buyer,newTokens);
        Transfer(this,_buyer,newTokens);
    }
    function burnTokens(address _owner) public
        onlyCrowdsaleManager
    {
        require(currentPhase == Phase.Migrating);
        uint tokens = balanceOf[_owner];
        require(tokens != 0);
        balanceOf[_owner] = 0;
        totalSupply -= tokens;
        LogBurn(_owner, tokens);
        Transfer(_owner, crowdsaleManager, tokens);
        if (totalSupply == 0) {
            currentPhase = Phase.Migrated;
            LogPhaseSwitch(Phase.Migrated);
        }
    }
    function setPresalePhase(Phase _nextPhase) public
        onlyEscrow
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
        require(canSwitchPhase);
        currentPhase = _nextPhase;
        LogPhaseSwitch(_nextPhase);
    }
    function withdrawEther(uint _amount) public
        onlyEscrow
    {
        require(namiMultiSigWallet != 0x0);
        if (this.balance > 0) {
            namiMultiSigWallet.transfer(_amount);
        }
    }
    function safeWithdraw(address _withdraw, uint _amount) public
        onlyEscrow
    {
        NamiMultiSigWallet namiWallet = NamiMultiSigWallet(namiMultiSigWallet);
        if (namiWallet.isOwner(_withdraw)) {
            _withdraw.transfer(_amount);
        }
    }
    function setCrowdsaleManager(address _mgr) public
        onlyEscrow
    {
        require(currentPhase != Phase.Migrating);
        crowdsaleManager = _mgr;
    }
    function _migrateToken(address _from, address _to)
        internal
    {
        PresaleToken presale = PresaleToken(namiPresale);
        uint256 newToken = presale.balanceOf(_from);
        require(newToken > 0);
        presale.burnTokens(_from);
        balanceOf[_to] = balanceOf[_to].add(newToken);
        totalSupply = totalSupply.add(newToken);
        LogMigrate(_from, _to, newToken);
        Transfer(this,_to,newToken);
    }
    function migrateToken(address _from, address _to) public
        onlyEscrow
    {
        _migrateToken(_from, _to);
    }
    function migrateForInvestor() public {
        _migrateToken(msg.sender, msg.sender);
    }
    event TransferToBuyer(address indexed _from, address indexed _to, uint _value, address indexed _seller);
    event TransferToExchange(address indexed _from, address indexed _to, uint _value, uint _price);
    function transferToExchange(address _to, uint _value, uint _price) public {
        uint codeLength;
        assembly {
            codeLength := extcodesize(_to)
        }
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        Transfer(msg.sender,_to,_value);
        if (codeLength > 0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallbackExchange(msg.sender, _value, _price);
            TransferToExchange(msg.sender, _to, _value, _price);
        }
    }
    function transferToBuyer(address _to, uint _value, address _buyer) public {
        uint codeLength;
        assembly {
            codeLength := extcodesize(_to)
        }
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        Transfer(msg.sender,_to,_value);
        if (codeLength > 0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallbackBuyer(msg.sender, _value, _buyer);
            TransferToBuyer(msg.sender, _to, _value, _buyer);
        }
    }
}
