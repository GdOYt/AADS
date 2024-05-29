contract Winner is WinnerEvents {
    using SafeMath for *;
    using NameFilter for string;
    string constant public name = "Im Winner Game";
    string constant public symbol = "IMW";
    bool public activated_ = false;
    uint256 public roundID_;
    uint256 private pIDCount_;
    mapping(address => uint256) public address2PID_;
    mapping(uint256 => WinnerDatasets.Player) public pID2Player_;
    mapping(uint256 => mapping(uint256 => WinnerDatasets.PlayerRound)) public pID2Round_;
    mapping(uint256 => mapping(uint256 => WinnerDatasets.PlayerOrder[])) public pID2Order_;
    mapping(uint256 => WinnerDatasets.Round) public rID2Round_;
    constructor()
        public
    {
        pIDCount_ = 0;
    }
     modifier isActivated() {
        require(activated_ == true, "the contract is not ready yet");
        _;
     }
    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;
        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }
    modifier isAdmin() {
        require( msg.sender == 0x74B25afBbd16Ef94d6a32c311d5c184a736850D3, "sorry admins only");
        _;
    }
    modifier isWithinLimits(uint256 _eth) {
        require(_eth >= 10000000000, "eth too small");
        require(_eth <= 100000000000000000000000, "eth too huge");
        _;    
    }
    function ()
    isActivated()
    isHuman()
    isWithinLimits(msg.value)
    public
    payable {
        buyCore(msg.sender, msg.value, "");
    }
    function buyKey()
    isActivated()
    isHuman()
    isWithinLimits(msg.value)
    public
    payable {
        buyCore(msg.sender, msg.value, "");
    }
    function buyKeyWithReff(string reff)
    isActivated()
    isHuman()
    isWithinLimits(msg.value)
    public
    payable {
        buyCore(msg.sender, msg.value, reff);
    }
    function buyKeyUseBalance(uint256 keys) 
    isActivated()
    isHuman()
    public {
        uint256 pID = address2PID_[msg.sender];
        require(pID > 0, "cannot find player");
        emit WinnerEvents.onBuyUseBalance
        (
            msg.sender, 
            keys, 
            now
        );
    }
    function buyName(string pname)
    isActivated()
    isHuman()
    isWithinLimits(msg.value)
    public
    payable {
        uint256 pID = address2PID_[msg.sender];
        if( pID == 0 ) {
            pIDCount_++;
            pID = pIDCount_;
            WinnerDatasets.Player memory player = WinnerDatasets.Player(pID, msg.sender, 0, 0, 0, 0, 0);
            WinnerDatasets.PlayerRound memory playerRound = WinnerDatasets.PlayerRound(0, 0, 0, 0, 0);
            pID2Player_[pID] = player;
            pID2Round_[pID][roundID_] = playerRound;
            address2PID_[msg.sender] = pID;
        }
        pID2Player_[pID].pname = pname.nameFilter();
        emit WinnerEvents.onBuyName
        (
            msg.sender, 
            pID2Player_[pID].pname, 
            msg.value, 
            now
        );
    }
    function buyCore(address addr, uint256 eth, string reff) 
    private {
        uint256 pID = address2PID_[addr];
        if( pID == 0 ) {
            pIDCount_++;
            pID = pIDCount_;
            WinnerDatasets.Player memory player = WinnerDatasets.Player(pID, addr, 0, 0, 0, 0, 0);
            WinnerDatasets.PlayerRound memory playerRound = WinnerDatasets.PlayerRound(0, 0, 0, 0, 0);
            pID2Player_[pID] = player;
            pID2Round_[pID][roundID_] = playerRound;
            address2PID_[addr] = pID;
        }
        emit WinnerEvents.onBuy
        (
            addr, 
            eth, 
            reff,
            now
        );
    }
    function activate() 
    isAdmin()
    public {
        require( activated_ == false, "contract is activated");
        activated_ = true;
        roundID_ = 1;
    }
    function inactivate()
    isAdmin()
    isActivated()
    public {
        activated_ = false;
    }
    function withdraw(address addr, uint256 eth)
    isActivated() 
    isAdmin() 
    isWithinLimits(eth) 
    public {
        uint pID = address2PID_[addr];
        require(pID > 0, "user not exist");
        addr.transfer(eth);
        emit WinnerEvents.onWithdraw
        (
            msg.sender, 
            eth, 
            now
        );
    }
    function upRoundID(uint256 roundID) 
    isAdmin()
    isActivated()
    public {
        require(roundID_ != roundID, "same to the current roundID");
        roundID_ = roundID;
        emit WinnerEvents.onUpRoundID
        (
            roundID
        );
    }
    function upPlayer(address addr, bytes32 pname, uint256 balance, uint256 interest, uint256 win, uint256 reff)
    isAdmin()
    isActivated()
    public {
        uint256 pID = address2PID_[addr];
        require( pID != 0, "cannot find the player");
        require( balance >= 0, "balance invalid");
        require( interest >= 0, "interest invalid");
        require( win >= 0, "win invalid");
        require( reff >= 0, "reff invalid");
        pID2Player_[pID].pname = pname;
        pID2Player_[pID].balance = balance;
        pID2Player_[pID].interest = interest;
        pID2Player_[pID].win = win;
        pID2Player_[pID].reff = reff;
        emit WinnerEvents.onUpPlayer
        (
            addr,
            pname,
            balance,
            interest,
            win,
            reff
        );
    }
    function upPlayerRound(address addr, uint256 roundID, uint256 eth, uint256 keys, uint256 interest, uint256 win, uint256 reff)
    isAdmin()
    isActivated() 
    public {
        uint256 pID = address2PID_[addr];
        require( pID != 0, "cannot find the player");
        require( roundID == roundID_, "not current round");
        require( eth >= 0, "eth invalid");
        require( keys >= 0, "keys invalid");
        require( interest >= 0, "interest invalid");
        require( win >= 0, "win invalid");
        require( reff >= 0, "reff invalid");
        pID2Round_[pID][roundID_].eth = eth;
        pID2Round_[pID][roundID_].keys = keys;
        pID2Round_[pID][roundID_].interest = interest;
        pID2Round_[pID][roundID_].win = win;
        pID2Round_[pID][roundID_].reff = reff;
        emit WinnerEvents.onUpPlayerRound
        (
            addr,
            roundID,
            eth,
            keys,
            interest,
            win,
            reff
        );
    }
    function addPlayerOrder(address addr, uint256 roundID, uint256 keys, uint256 eth, uint256 otype, uint256 keysAvailable, uint256 keysEth) 
    isAdmin()
    isActivated()
    public {
        uint256 pID = address2PID_[addr];
        require( pID != 0, "cannot find the player");
        require( roundID == roundID_, "not current round");
        require( keys >= 0, "keys invalid");
        require( eth >= 0, "eth invalid");
        require( otype >= 0, "type invalid");
        require( keysAvailable >= 0, "keysAvailable invalid");
        pID2Round_[pID][roundID_].eth = keysEth;
        pID2Round_[pID][roundID_].keys = keysAvailable;
        WinnerDatasets.PlayerOrder memory playerOrder = WinnerDatasets.PlayerOrder(keys, eth, otype);
        pID2Order_[pID][roundID_].push(playerOrder);
        emit WinnerEvents.onAddPlayerOrder
        (
            addr,
            keys,
            eth,
            otype
        );
    }
    function upRound(uint256 roundID, address leader, uint256 start, uint256 end, bool ended, uint256 keys, uint256 eth, uint256 pool, uint256 interest, uint256 win, uint256 reff)
    isAdmin()
    isActivated()
    public {
        require( roundID == roundID_, "not current round");
        uint256 pID = address2PID_[leader];
        require( pID != 0, "cannot find the leader");
        require( end >= start, "start end invalid");
        require( keys >= 0, "keys invalid");
        require( eth >= 0, "eth invalid");
        require( pool >= 0, "pool invalid");
        require( interest >= 0, "interest invalid");
        require( win >= 0, "win invalid");
        require( reff >= 0, "reff invalid");
        rID2Round_[roundID_].leader = leader;
        rID2Round_[roundID_].start = start;
        rID2Round_[roundID_].end = end;
        rID2Round_[roundID_].ended = ended;
        rID2Round_[roundID_].keys = keys;
        rID2Round_[roundID_].eth = eth;
        rID2Round_[roundID_].pool = pool;
        rID2Round_[roundID_].interest = interest;
        rID2Round_[roundID_].win = win;
        rID2Round_[roundID_].reff = reff;
        emit WinnerEvents.onUpRound
        (
            roundID,
            leader,
            start,
            end,
            ended,
            keys,
            eth,
            pool,
            interest,
            win,
            reff
        );
    }
}
