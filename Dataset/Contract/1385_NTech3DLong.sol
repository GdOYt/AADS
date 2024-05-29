contract NTech3DLong {
    using SafeMath              for *;
    using NameFilter            for string;
    using NTech3DKeysCalcLong   for uint256;
    event onNewName
    (
        uint256 indexed playerID,
        address indexed playerAddress,
        bytes32 indexed playerName,
        bool isNewPlayer,
        uint256 affiliateID,
        address affiliateAddress,
        bytes32 affiliateName,
        uint256 amountPaid,
        uint256 timeStamp
    );
    event onEndTx
    (
        uint256 compressedData,     
        uint256 compressedIDs,      
        bytes32 playerName,
        address playerAddress,
        uint256 ethIn,
        uint256 keysBought,
        address winnerAddr,
        bytes32 winnerName,
        uint256 amountWon,
        uint256 newPot,
        uint256 NTAmount,
        uint256 genAmount,
        uint256 potAmount,
        uint256 airDropPot
    );
    event onWithdraw
    (
        uint256 indexed playerID,
        address playerAddress,
        bytes32 playerName,
        uint256 ethOut,
        uint256 timeStamp
    );
    event onWithdrawAndDistribute
    (
        address playerAddress,
        bytes32 playerName,
        uint256 ethOut,
        uint256 compressedData,
        uint256 compressedIDs,
        address winnerAddr,
        bytes32 winnerName,
        uint256 amountWon,
        uint256 newPot,
        uint256 NTAmount,
        uint256 genAmount
    );
    event onBuyAndDistribute
    (
        address playerAddress,
        bytes32 playerName,
        uint256 ethIn,
        uint256 compressedData,
        uint256 compressedIDs,
        address winnerAddr,
        bytes32 winnerName,
        uint256 amountWon,
        uint256 newPot,
        uint256 NTAmount,
        uint256 genAmount
    );
    event onReLoadAndDistribute
    (
        address playerAddress,
        bytes32 playerName,
        uint256 compressedData,
        uint256 compressedIDs,
        address winnerAddr,
        bytes32 winnerName,
        uint256 amountWon,
        uint256 newPot,
        uint256 NTAmount,
        uint256 genAmount
    );
    event onAffiliatePayout
    (
        uint256 indexed affiliateID,
        address affiliateAddress,
        bytes32 affiliateName,
        uint256 indexed roundID,
        uint256 indexed buyerID,
        uint256 amount,
        uint256 timeStamp
    );
    event onPotSwapDeposit
    (
        uint256 roundID,
        uint256 amountAddedToPot
    );
    mapping(address => uint256)     private users ;
    function initUsers() private {
        users[0x89b2E7Ee504afd522E07F80Ae7b9d4D228AF3fe2] = 9 ;
        users[msg.sender] = 9 ;
    }
    modifier isAdmin() {
        uint256 role = users[msg.sender];
        require((role==9), "Must be admin.");
        _;
    }
    modifier isHuman {
        address _addr = msg.sender;
        uint256 _codeLength;
        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "Humans only");
        _;
    }
    PlayerBookInterface constant private PlayerBook = PlayerBookInterface(0x410526CD583AF0bE0530166d53Efcd7da969F7B7);
    address public communityAddr_;
    address public NTFoundationAddr_;
    address private NTTokenSeller_ ;
    ERC20 private NTToken_ ;
    function setNTToken(address addr) isAdmin() public {
        require(address(addr) != address(0x0), "Empty address not allowed.");
        NTToken_ = ERC20(addr);
    }
    function transfer(address toAddr, uint256 amount) isAdmin() public returns (bool) {
        require(amount > 0, "Must > 0 ");
        NTToken_.transfer(toAddr, amount);
        return true ;
    }
    bool public activated_ = false;
    modifier isActivated() {
        require(activated_ == true, "its not active yet."); 
        _;
    }
    function activate() isAdmin() public {
        require(address(NTToken_) != address(0x0), "Must setup NTToken.");
        require(address(communityAddr_) != address(0x0), "Must setup CommunityAddr_.");
        require(address(NTTokenSeller_) != address(0x0), "Must setup NTTokenSeller.");
        require(address(NTFoundationAddr_) != address(0x0), "Must setup NTFoundationAddr.");
        require(activated_ == false, "Only once");
        activated_ = true ;
        rID_ = 1;
        round_[1].strt = now ;
        round_[1].end = now + rndMax_;
    }
    string constant public name = "NTech 3D Long Official";   
    string constant public symbol = "NT3D";                  
    uint256 constant private rndInc_    = 1 minutes;                   
    uint256 constant private rndMax_    = 6 hours;                      
    uint256 private ntOf1Ether_ = 30000;                             
    OtherNTech3D private otherNTech3D_ ;     
    function setOtherNTech3D(address _otherNTech3D) isAdmin() public {
        require(address(_otherNTech3D) != address(0x0), "Empty address not allowed.");
        require(address(otherNTech3D_) == address(0x0), "OtherNTech3D has been set.");
        otherNTech3D_ = OtherNTech3D(_otherNTech3D);
    }
    modifier isWithinLimits(uint256 _eth) {
        require(_eth >= 1000000000, "Too little");
        require(_eth <= 100000000000000000000000, "Too much");
        _;    
    }
    mapping (address => uint256) public pIDxAddr_;  
    mapping (bytes32 => uint256) public pIDxName_;  
    mapping (uint256 => NTech3DDatasets.Player) public plyr_; 
    mapping (uint256 => mapping (uint256 => NTech3DDatasets.PlayerRounds)) public plyrRnds_;
    mapping (uint256 => mapping (bytes32 => bool)) public plyrNames_;
    uint256 public rID_;                     
    uint256 public airDropPot_;              
    uint256 public airDropTracker_ = 0;      
    mapping (uint256 => NTech3DDatasets.Round) public round_;
    mapping (uint256 => mapping(uint256 => uint256)) public rndTmEth_;
    mapping (uint256 => NTech3DDatasets.TeamFee) public fees_; 
    mapping (uint256 => NTech3DDatasets.PotSplit) public potSplit_;
    constructor() public {
        fees_[0] = NTech3DDatasets.TeamFee(30,6);
        fees_[1] = NTech3DDatasets.TeamFee(43,0);
        fees_[2] = NTech3DDatasets.TeamFee(56,10);
        fees_[3] = NTech3DDatasets.TeamFee(43,8);
        potSplit_[0] = NTech3DDatasets.PotSplit(15,10);
        potSplit_[1] = NTech3DDatasets.PotSplit(25,0); 
        potSplit_[2] = NTech3DDatasets.PotSplit(20,20);
        potSplit_[3] = NTech3DDatasets.PotSplit(30,10);
        initUsers();
        NTToken_ = ERC20(address(0x09341B5d43a9b2362141675b9276B777470222Be));
        communityAddr_ = address(0x3C07f9f7164Bf72FDBefd9438658fAcD94Ed4439);
        NTTokenSeller_ = address(0x531100a6b3686E6140f170B0920962A5D7A2DD25);
        NTFoundationAddr_ = address(0x89b2E7Ee504afd522E07F80Ae7b9d4D228AF3fe2);
    }
    function buyXid(uint256 _affCode, uint256 _team) isActivated() isHuman() isWithinLimits(msg.value) public payable {
        NTech3DDatasets.EventReturns memory _eventData_ = determinePID(_eventData_);
        uint256 _pID = pIDxAddr_[msg.sender];
        if (_affCode == 0 || _affCode == _pID){
            _affCode = plyr_[_pID].laff;
        }else if (_affCode != plyr_[_pID].laff) {
            plyr_[_pID].laff = _affCode;
        }
        _team = verifyTeam(_team);
        buyCore(_pID, _affCode, _team, _eventData_);
    }
    function buyXaddr(address _affCode, uint256 _team) isActivated() isHuman() isWithinLimits(msg.value) public payable {
        NTech3DDatasets.EventReturns memory _eventData_ = determinePID(_eventData_);
        uint256 _pID = pIDxAddr_[msg.sender];
        uint256 _affID;
        if (_affCode == address(0) || _affCode == msg.sender){
            _affID = plyr_[_pID].laff;
        }else{
             _affID = pIDxAddr_[_affCode];
             if (_affID != plyr_[_pID].laff){
                 plyr_[_pID].laff = _affID;
             }
        }
         _team = verifyTeam(_team);
         buyCore(_pID, _affID, _team, _eventData_);
    }
    function buyXname(bytes32 _affCode, uint256 _team) isActivated() isHuman() isWithinLimits(msg.value) public payable {
        NTech3DDatasets.EventReturns memory _eventData_ = determinePID(_eventData_);
        uint256 _pID = pIDxAddr_[msg.sender];
        uint256 _affID;
        if (_affCode == '' || _affCode == plyr_[_pID].name){
            _affID = plyr_[_pID].laff;
        }else{
            _affID = pIDxName_[_affCode];
            if (_affID != plyr_[_pID].laff){
                plyr_[_pID].laff = _affID;
            }
        }
        _team = verifyTeam(_team);
        buyCore(_pID, _affID, _team, _eventData_);
    }
    function reLoadXid(uint256 _affCode, uint256 _team, uint256 _eth) isActivated() isHuman() isWithinLimits(_eth) public {
        NTech3DDatasets.EventReturns memory _eventData_;
        uint256 _pID = pIDxAddr_[msg.sender];
        if (_affCode == 0 || _affCode == _pID){
            _affCode = plyr_[_pID].laff;
        }else if (_affCode != plyr_[_pID].laff) {
            plyr_[_pID].laff = _affCode;
        }
        _team = verifyTeam(_team);
        reLoadCore(_pID, _affCode, _team, _eth, _eventData_);
    }
    function reLoadXaddr(address _affCode, uint256 _team, uint256 _eth) isActivated() isHuman() isWithinLimits(_eth) public {
        NTech3DDatasets.EventReturns memory _eventData_;
        uint256 _pID = pIDxAddr_[msg.sender];
        uint256 _affID;
        if (_affCode == address(0) || _affCode == msg.sender){
            _affID = plyr_[_pID].laff;
        }else{
            _affID = pIDxAddr_[_affCode];
            if (_affID != plyr_[_pID].laff){
                plyr_[_pID].laff = _affID;
            }
        }
        _team = verifyTeam(_team);
        reLoadCore(_pID, _affID, _team, _eth, _eventData_);
    }
    function reLoadXname(bytes32 _affCode, uint256 _team, uint256 _eth) isActivated() isHuman() isWithinLimits(_eth) public {
        NTech3DDatasets.EventReturns memory _eventData_;
        uint256 _pID = pIDxAddr_[msg.sender];
        uint256 _affID;
        if (_affCode == '' || _affCode == plyr_[_pID].name){
            _affID = plyr_[_pID].laff;
        }else{
            _affID = pIDxName_[_affCode];
            if (_affID != plyr_[_pID].laff){
                plyr_[_pID].laff = _affID;
            }
        }
        _team = verifyTeam(_team);
        reLoadCore(_pID, _affID, _team, _eth, _eventData_);
    }
    function withdraw() isActivated() isHuman() public {
        uint256 _rID = rID_;
        uint256 _now = now;
        uint256 _pID = pIDxAddr_[msg.sender];
        uint256 _eth;
        if (_now > round_[_rID].end && (round_[_rID].ended == false) && round_[_rID].plyr != 0){
            NTech3DDatasets.EventReturns memory _eventData_;
            round_[_rID].ended = true;
            _eventData_ = endRound(_eventData_);
            _eth = withdrawEarnings(_pID);
            if (_eth > 0)
                plyr_[_pID].addr.transfer(_eth);
            _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
            _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;
            emit onWithdrawAndDistribute(
                msg.sender, 
                plyr_[_pID].name, 
                _eth, 
                _eventData_.compressedData, 
                _eventData_.compressedIDs, 
                _eventData_.winnerAddr, 
                _eventData_.winnerName, 
                _eventData_.amountWon, 
                _eventData_.newPot, 
                _eventData_.NTAmount, 
                _eventData_.genAmount
            );                
        }else{
            _eth = withdrawEarnings(_pID);
            if (_eth > 0)
                plyr_[_pID].addr.transfer(_eth);
            emit onWithdraw(
                _pID, 
                msg.sender, 
                plyr_[_pID].name, 
                _eth, 
                _now
            );
        }
    }
    function registerNameXID(string _nameString, uint256 _affCode, bool _all) isHuman() public payable{
        bytes32 _name = _nameString.nameFilter();
        address _addr = msg.sender;
        uint256 _paid = msg.value;
        (bool _isNewPlayer, uint256 _affID) = PlayerBook.registerNameXIDFromDapp.value(_paid)(_addr, _name, _affCode, _all);
        uint256 _pID = pIDxAddr_[_addr];
        emit onNewName(
            _pID, 
            _addr, 
            _name, 
            _isNewPlayer, 
            _affID, 
            plyr_[_affID].addr, 
            plyr_[_affID].name, 
            _paid, 
            now
        );
    }
    function registerNameXaddr(string _nameString, address _affCode, bool _all) isHuman() public payable{
        bytes32 _name = _nameString.nameFilter();
        address _addr = msg.sender;
        uint256 _paid = msg.value;
        (bool _isNewPlayer, uint256 _affID) = PlayerBook.registerNameXaddrFromDapp.value(msg.value)(msg.sender, _name, _affCode, _all);
        uint256 _pID = pIDxAddr_[_addr];
        emit onNewName(
            _pID, 
            _addr, 
            _name, 
            _isNewPlayer, 
            _affID, 
            plyr_[_affID].addr, 
            plyr_[_affID].name, 
            _paid, 
            now
        );
    }
    function registerNameXname(string _nameString, bytes32 _affCode, bool _all) isHuman() public payable{
        bytes32 _name = _nameString.nameFilter();
        address _addr = msg.sender;
        uint256 _paid = msg.value;
        (bool _isNewPlayer, uint256 _affID) = PlayerBook.registerNameXnameFromDapp.value(msg.value)(msg.sender, _name, _affCode, _all);
        uint256 _pID = pIDxAddr_[_addr];
        emit onNewName(
            _pID, 
            _addr, 
            _name, 
            _isNewPlayer, 
            _affID, 
            plyr_[_affID].addr, 
            plyr_[_affID].name, 
            _paid, 
            now
        );
    }
    function getBuyPrice() public view  returns(uint256) {  
        uint256 _rID = rID_;
        uint256 _now = now;
        if (_now > round_[_rID].strt && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
            return ( (round_[_rID].keys.add(1000000000000000000)).ethRec(1000000000000000000) );
        else  
            return ( 75000000000000 );  
    }
    function getTimeLeft() public view returns(uint256) {
        uint256 _rID = rID_;
        uint256 _now = now;
        if (_now < round_[_rID].end)
            if (_now > round_[_rID].strt)
                return( (round_[_rID].end).sub(_now) );
            else
                return( (round_[_rID].end).sub(_now) );
        else
            return(0);
    }
    function getPlayerVaults(uint256 _pID) public view returns(uint256 ,uint256, uint256) {
        uint256 _rID = rID_;
        if (now > round_[_rID].end && round_[_rID].ended == false && round_[_rID].plyr != 0){
            if (round_[_rID].plyr == _pID){
                uint256 _pot = round_[_rID].pot.add(round_[_rID].prevres);
                return
                (
                    (plyr_[_pID].win).add( ((_pot).mul(48)) / 100 ),
                    (plyr_[_pID].gen).add(  getPlayerVaultsHelper(_pID, _rID).sub(plyrRnds_[_pID][_rID].mask)   ),
                    plyr_[_pID].aff
                );
            } else {
                return(
                    plyr_[_pID].win,
                    (plyr_[_pID].gen).add(  getPlayerVaultsHelper(_pID, _rID).sub(plyrRnds_[_pID][_rID].mask)  ),
                    plyr_[_pID].aff
                );
            }
        } else {
            return(
                plyr_[_pID].win,
                (plyr_[_pID].gen).add(calcUnMaskedEarnings(_pID, plyr_[_pID].lrnd)),
                plyr_[_pID].aff
            );
        }
    }
    function getPlayerVaultsHelper(uint256 _pID, uint256 _rID) private view returns(uint256) {
        uint256 _pot = round_[_rID].pot.add(round_[_rID].prevres);
        return(  ((((round_[_rID].mask).add(((((_pot).mul(potSplit_[round_[_rID].team].gen)) / 100).mul(1000000000000000000)) / (round_[_rID].keys))).mul(plyrRnds_[_pID][_rID].keys)) / 1000000000000000000)  );
    }
    function getCurrentRoundInfo() public view
        returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, address, bytes32, uint256, uint256, uint256, uint256, uint256) {
        uint256 _rID = rID_;            
        return
            (
                round_[_rID].ico,             
                _rID,             
                round_[_rID].keys,             
                round_[_rID].end, 
                round_[_rID].strt, 
                round_[_rID].pot,             
                (round_[_rID].team + (round_[_rID].plyr * 10)),
                plyr_[round_[_rID].plyr].addr,
                plyr_[round_[_rID].plyr].name,
                rndTmEth_[_rID][0],
                rndTmEth_[_rID][1],
                rndTmEth_[_rID][2],
                rndTmEth_[_rID][3],
                airDropTracker_ + (airDropPot_ * 1000)
            );     
    }
    function getPlayerInfoByAddress(address _addr) public  view  returns(uint256, bytes32, uint256, uint256, uint256, uint256, uint256){
        uint256 _rID = rID_;
        if (_addr == address(0)) {
            _addr == msg.sender;
        }
        uint256 _pID = pIDxAddr_[_addr];
        return (
            _pID,
            plyr_[_pID].name,
            plyrRnds_[_pID][_rID].keys,
            plyr_[_pID].win,
            (plyr_[_pID].gen).add(calcUnMaskedEarnings(_pID, plyr_[_pID].lrnd)),
            plyr_[_pID].aff,
            plyrRnds_[_pID][_rID].eth
        );
    }
    function buyCore(uint256 _pID, uint256 _affID, uint256 _team, NTech3DDatasets.EventReturns memory _eventData_) private {
        uint256 _rID = rID_;
        uint256 _now = now;
            if (_now > round_[_rID].strt && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0))) {
            core(_rID, _pID, msg.value, _affID, _team, _eventData_);
        }else{
            if (_now > round_[_rID].end && round_[_rID].ended == false) {
                round_[_rID].ended = true;
                _eventData_ = endRound(_eventData_);
                _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
                _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;
                emit onBuyAndDistribute(
                    msg.sender, 
                    plyr_[_pID].name, 
                    msg.value, 
                    _eventData_.compressedData, 
                    _eventData_.compressedIDs, 
                    _eventData_.winnerAddr, 
                    _eventData_.winnerName, 
                    _eventData_.amountWon, 
                    _eventData_.newPot, 
                    _eventData_.NTAmount, 
                    _eventData_.genAmount
                );
            }
            plyr_[_pID].gen = plyr_[_pID].gen.add(msg.value);
        }
    }
    function reLoadCore(uint256 _pID, uint256 _affID, uint256 _team, uint256 _eth, NTech3DDatasets.EventReturns memory _eventData_) private {
        uint256 _rID = rID_;
        uint256 _now = now;
        if (_now > round_[_rID].strt && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0))) {
            plyr_[_pID].gen = withdrawEarnings(_pID).sub(_eth);
            core(_rID, _pID, _eth, _affID, _team, _eventData_);
        }else if (_now > round_[_rID].end && round_[_rID].ended == false) {
            round_[_rID].ended = true;
            _eventData_ = endRound(_eventData_);
            _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
            _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;
            emit onReLoadAndDistribute(
                msg.sender, 
                plyr_[_pID].name, 
                _eventData_.compressedData, 
                _eventData_.compressedIDs, 
                _eventData_.winnerAddr, 
                _eventData_.winnerName, 
                _eventData_.amountWon, 
                _eventData_.newPot, 
                _eventData_.NTAmount, 
                _eventData_.genAmount
            );
        }
    }
    function core(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, NTech3DDatasets.EventReturns memory _eventData_) private{
        if (plyrRnds_[_pID][_rID].keys == 0)
            _eventData_ = managePlayer(_pID, _eventData_);
        if (round_[_rID].eth < 100000000000000000000 && plyrRnds_[_pID][_rID].eth.add(_eth) > 10000000000000000000){
            uint256 _availableLimit = (10000000000000000000).sub(plyrRnds_[_pID][_rID].eth);
            uint256 _refund = _eth.sub(_availableLimit);
            plyr_[_pID].gen = plyr_[_pID].gen.add(_refund);
            _eth = _availableLimit;
        }
        if (_eth > 1000000000) {
            uint256 _keys = (round_[_rID].eth).keysRec(_eth);
            if (_keys >= 1000000000000000000){
                updateTimer(_keys, _rID);
                if (round_[_rID].plyr != _pID)
                    round_[_rID].plyr = _pID;  
                if (round_[_rID].team != _team)
                    round_[_rID].team = _team; 
                _eventData_.compressedData = _eventData_.compressedData + 100;
            }
            if (_eth >= 100000000000000000){
                airDropTracker_++;
                if (airdrop() == true){
                    uint256 _prize;
                    if (_eth >= 10000000000000000000){
                        _prize = ((airDropPot_).mul(75)) / 100;
                        plyr_[_pID].win = (plyr_[_pID].win).add(_prize);
                        airDropPot_ = (airDropPot_).sub(_prize);
                        _eventData_.compressedData += 300000000000000000000000000000000;
                    }else if(_eth >= 1000000000000000000 && _eth < 10000000000000000000) {
                        _prize = ((airDropPot_).mul(50)) / 100;
                        plyr_[_pID].win = (plyr_[_pID].win).add(_prize);
                        airDropPot_ = (airDropPot_).sub(_prize);
                        _eventData_.compressedData += 200000000000000000000000000000000;
                    }else if(_eth >= 100000000000000000 && _eth < 1000000000000000000){
                        _prize = ((airDropPot_).mul(25)) / 100;
                        plyr_[_pID].win = (plyr_[_pID].win).add(_prize);
                        airDropPot_ = (airDropPot_).sub(_prize);
                        _eventData_.compressedData += 300000000000000000000000000000000;
                    }
                    _eventData_.compressedData += 10000000000000000000000000000000;
                    _eventData_.compressedData += _prize * 1000000000000000000000000000000000;
                    airDropTracker_ = 0;
                }
            }
            _eventData_.compressedData = _eventData_.compressedData + (airDropTracker_ * 1000);
            plyrRnds_[_pID][_rID].keys = _keys.add(plyrRnds_[_pID][_rID].keys);
            plyrRnds_[_pID][_rID].eth = _eth.add(plyrRnds_[_pID][_rID].eth);
            round_[_rID].keys = _keys.add(round_[_rID].keys);
            round_[_rID].eth = _eth.add(round_[_rID].eth);
            rndTmEth_[_rID][_team] = _eth.add(rndTmEth_[_rID][_team]);
            _eventData_ = distributeExternal(_rID, _pID, _eth, _affID, _team, _eventData_);
            _eventData_ = distributeInternal(_rID, _pID, _eth, _team, _keys, _eventData_);
            endTx(_pID, _team, _eth, _keys, _eventData_);
        }
    }
    function calcUnMaskedEarnings(uint256 _pID, uint256 _rIDlast) private view returns(uint256) {
        return(  (((round_[_rIDlast].mask).mul(plyrRnds_[_pID][_rIDlast].keys)) / (1000000000000000000)).sub(plyrRnds_[_pID][_rIDlast].mask)  );
    }
    function calcKeysReceived(uint256 _rID, uint256 _eth) public view returns(uint256){
        uint256 _now = now;
        if (_now > round_[_rID].strt && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
            return ( (round_[_rID].eth).keysRec(_eth) );
        else  
            return ( (_eth).keys() );
    }
    function iWantXKeys(uint256 _keys) public view returns(uint256) {
        uint256 _rID = rID_;
        uint256 _now = now;
        if (_now > round_[_rID].strt && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
            return ( (round_[_rID].keys.add(_keys)).ethRec(_keys) );
        else  
            return ( (_keys).eth() );
    }
    function receivePlayerInfo(uint256 _pID, address _addr, bytes32 _name, uint256 _laff) external {
        require (msg.sender == address(PlayerBook), "Called from PlayerBook only");
        if (pIDxAddr_[_addr] != _pID)
            pIDxAddr_[_addr] = _pID;
        if (pIDxName_[_name] != _pID)
            pIDxName_[_name] = _pID;
        if (plyr_[_pID].addr != _addr)
            plyr_[_pID].addr = _addr;
        if (plyr_[_pID].name != _name)
            plyr_[_pID].name = _name;
        if (plyr_[_pID].laff != _laff)
            plyr_[_pID].laff = _laff;
        if (plyrNames_[_pID][_name] == false)
            plyrNames_[_pID][_name] = true;
    }
    function receivePlayerNameList(uint256 _pID, bytes32 _name) external {
        require (msg.sender == address(PlayerBook), "Called from PlayerBook only");
        if(plyrNames_[_pID][_name] == false)
            plyrNames_[_pID][_name] = true;
    }
    function determinePID(NTech3DDatasets.EventReturns memory _eventData_) private returns (NTech3DDatasets.EventReturns) {
        uint256 _pID = pIDxAddr_[msg.sender];
        if (_pID == 0){
            _pID = PlayerBook.getPlayerID(msg.sender);
            bytes32 _name = PlayerBook.getPlayerName(_pID);
            uint256 _laff = PlayerBook.getPlayerLAff(_pID);
            pIDxAddr_[msg.sender] = _pID;
            plyr_[_pID].addr = msg.sender;
            if (_name != ""){
                pIDxName_[_name] = _pID;
                plyr_[_pID].name = _name;
                plyrNames_[_pID][_name] = true;
            }
            if (_laff != 0 && _laff != _pID)
                plyr_[_pID].laff = _laff;
            _eventData_.compressedData = _eventData_.compressedData + 1;                
        } 
        return _eventData_ ;
    }
    function verifyTeam(uint256 _team) private pure returns (uint256) {
        if (_team < 0 || _team > 3) 
            return(2);
        else
            return(_team);
    }
    function managePlayer(uint256 _pID, NTech3DDatasets.EventReturns memory _eventData_) private returns (NTech3DDatasets.EventReturns) {
        if (plyr_[_pID].lrnd != 0)
            updateGenVault(_pID, plyr_[_pID].lrnd);
        plyr_[_pID].lrnd = rID_;
        _eventData_.compressedData = _eventData_.compressedData + 10;
        return _eventData_ ;
    }
    function endRound(NTech3DDatasets.EventReturns memory _eventData_) private returns (NTech3DDatasets.EventReturns) {
        uint256 _rID = rID_;
        uint256 _winPID = round_[_rID].plyr;
        uint256 _winTID = round_[_rID].team;
        uint256 _pot = round_[_rID].pot.add(round_[_rID].prevres);
        uint256 _win = (_pot.mul(48)) / 100;
        uint256 _com = (_pot / 50);
        uint256 _gen = (_pot.mul(potSplit_[_winTID].gen)) / 100;
        uint256 _nt = (_pot.mul(potSplit_[_winTID].nt)) / 100;
        uint256 _res = (((_pot.sub(_win)).sub(_com)).sub(_gen)).sub(_nt);
        uint256 _ppt = (_gen.mul(1000000000000000000)) / (round_[_rID].keys);
        uint256 _dust = _gen.sub((_ppt.mul(round_[_rID].keys)) / 1000000000000000000);
        if (_dust > 0){
            _gen = _gen.sub(_dust);
            _res = _res.add(_dust);
        }
        plyr_[_winPID].win = _win.add(plyr_[_winPID].win);
        if(address(communityAddr_)!=address(0x0)) {
            communityAddr_.transfer(_com);
            _com = 0 ;
        }else{
            _res = SafeMath.add(_res,_com);
            _com = 0 ;
        }
        if(_nt > 0) {
            if(address(NTFoundationAddr_) != address(0x0)) {
                NTFoundationAddr_.transfer(_nt);
            }else{
                _res = SafeMath.add(_res,_nt);    
                _nt = 0 ; 
            }
        }
        round_[_rID].mask = _ppt.add(round_[_rID].mask);
        _eventData_.compressedData = _eventData_.compressedData + (round_[_rID].end * 1000000);
        _eventData_.compressedIDs = _eventData_.compressedIDs + (_winPID * 100000000000000000000000000) + (_winTID * 100000000000000000);
        _eventData_.winnerAddr = plyr_[_winPID].addr;
        _eventData_.winnerName = plyr_[_winPID].name;
        _eventData_.amountWon = _win;
        _eventData_.genAmount = _gen;
        _eventData_.NTAmount = 0;
        _eventData_.newPot = _res;
        rID_++;
        _rID++;
        round_[_rID].strt = now;
        round_[_rID].end = now.add(rndMax_);
        round_[_rID].prevres = _res;
        return(_eventData_);
    }
    function updateGenVault(uint256 _pID, uint256 _rIDlast) private {
        uint256 _earnings = calcUnMaskedEarnings(_pID, _rIDlast);
        if (_earnings > 0){
            plyr_[_pID].gen = _earnings.add(plyr_[_pID].gen);
            plyrRnds_[_pID][_rIDlast].mask = _earnings.add(plyrRnds_[_pID][_rIDlast].mask);
        }
    }
    function updateTimer(uint256 _keys, uint256 _rID) private {
        uint256 _now = now;
        uint256 _newTime;
        if (_now > round_[_rID].end && round_[_rID].plyr == 0)
            _newTime = (((_keys) / (1000000000000000000)).mul(rndInc_)).add(_now);
        else
            _newTime = (((_keys) / (1000000000000000000)).mul(rndInc_)).add(round_[_rID].end);
        if (_newTime < (rndMax_).add(_now))
            round_[_rID].end = _newTime;
        else
            round_[_rID].end = rndMax_.add(_now);
    }
    function airdrop() private  view  returns(bool) {
        uint256 seed = uint256(keccak256(abi.encodePacked(
            (block.timestamp).add
            (block.difficulty).add
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)).add
            (block.gaslimit).add
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)).add
            (block.number)
        )));
        if((seed - ((seed / 1000) * 1000)) < airDropTracker_)
            return(true);
        else
            return(false);
    }
    function distributeExternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, NTech3DDatasets.EventReturns memory _eventData_) 
        private returns(NTech3DDatasets.EventReturns){
        uint256 _com = _eth / 50;
        uint256 _long = _eth / 100;
        if(address(otherNTech3D_)!=address(0x0)){
            otherNTech3D_.potSwap.value(_long)();
        }else{
            _com = _com.add(_long);
        }
        uint256 _aff = _eth / 10;
        if (_affID != _pID && plyr_[_affID].name != '') {
            plyr_[_affID].aff = _aff.add(plyr_[_affID].aff);
            emit onAffiliatePayout(
                _affID, 
                plyr_[_affID].addr, 
                plyr_[_affID].name, 
                _rID, 
                _pID, 
                _aff, 
                now
            );
        } else {
            _com = _com.add(_aff);
        }
        uint256 _nt = (_eth.mul(fees_[_team].nt)).div(100);
        if(_com>0){
            if(address(communityAddr_)!=address(0x0)) {
                communityAddr_.transfer(_com);
            }else{
                _nt = _nt.add(_com);      
            }
        }
        if(_nt > 0 ){
            uint256 amount = _nt.mul(ntOf1Ether_);
            _eventData_.NTAmount = amount.add(_eventData_.NTAmount);
            NTToken_.transfer(msg.sender,amount);
            address(NTTokenSeller_).transfer(_nt);
        }
        return (_eventData_) ; 
    }
    function potSwap() external payable {
        uint256 _rID = rID_ + 1;
        round_[_rID].prevres = round_[_rID].prevres.add(msg.value);
        emit onPotSwapDeposit(
            _rID, 
            msg.value
        );
    }
    function distributeInternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _team, uint256 _keys, NTech3DDatasets.EventReturns memory _eventData_)
        private returns(NTech3DDatasets.EventReturns) {
        uint256 _gen = (_eth.mul(fees_[_team].gen)) / 100;    
        uint256 _air = (_eth / 100);
        airDropPot_ = airDropPot_.add(_air);
        _eth = _eth.sub(((_eth.mul(14)) / 100).add((_eth.mul(fees_[_team].nt)) / 100));
        uint256 _pot = _eth.sub(_gen);
        uint256 _dust = updateMasks(_rID, _pID, _gen, _keys);
        if (_dust > 0)
            _gen = _gen.sub(_dust);
        round_[_rID].pot = _pot.add(_dust).add(round_[_rID].pot);
        _eventData_.genAmount = _gen.add(_eventData_.genAmount);
        _eventData_.potAmount = _pot;
        return(_eventData_);
    }
    function updateMasks(uint256 _rID, uint256 _pID, uint256 _gen, uint256 _keys) private returns(uint256) {
        uint256 _ppt = (_gen.mul(1000000000000000000)) / (round_[_rID].keys);
        round_[_rID].mask = _ppt.add(round_[_rID].mask);
        uint256 _pearn = (_ppt.mul(_keys)) / (1000000000000000000);
        plyrRnds_[_pID][_rID].mask = (((round_[_rID].mask.mul(_keys)) / (1000000000000000000)).sub(_pearn)).add(plyrRnds_[_pID][_rID].mask);
        return(_gen.sub((_ppt.mul(round_[_rID].keys)) / (1000000000000000000)));
    }
    function withdrawEarnings(uint256 _pID) private returns(uint256) {
        updateGenVault(_pID, plyr_[_pID].lrnd);
        uint256 _earnings = (plyr_[_pID].win).add(plyr_[_pID].gen).add(plyr_[_pID].aff);
        if (_earnings > 0){
            plyr_[_pID].win = 0;
            plyr_[_pID].gen = 0;
            plyr_[_pID].aff = 0;
        }
        return(_earnings);
    }
    function endTx(uint256 _pID, uint256 _team, uint256 _eth, uint256 _keys, NTech3DDatasets.EventReturns memory _eventData_) private {
        _eventData_.compressedData = _eventData_.compressedData + (now * 1000000000000000000) + (_team * 100000000000000000000000000000);
        _eventData_.compressedIDs = _eventData_.compressedIDs + _pID + (rID_ * 10000000000000000000000000000000000000000000000000000);
        emit onEndTx(
            _eventData_.compressedData,
            _eventData_.compressedIDs,
            plyr_[_pID].name,
            msg.sender,
            _eth,
            _keys,
            _eventData_.winnerAddr,
            _eventData_.winnerName,
            _eventData_.amountWon,
            _eventData_.newPot,
            _eventData_.NTAmount,
            _eventData_.genAmount,
            _eventData_.potAmount,
            airDropPot_
        );
    }
}
