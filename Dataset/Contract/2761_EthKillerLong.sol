contract EthKillerLong is modularLong {
    using SafeMath for *;
    using NameFilter for string;
    using F3DKeysCalcLong for uint256;
    address public teamAddress = 0xc2daaf4e63af76b394dea9a98a1fa650fc626b91;
    function setTeamAddress(address addr) isOwner() public {
        teamAddress = addr;
    }
    function gameSettings(uint256 rndExtra, uint256 rndGap) isOwner() public {
        rndExtra_ = rndExtra;
        rndGap_ = rndGap;
    }
    string constant public name = "Eth Killer Long Official";
    string constant public symbol = "EKL";
    uint256 private rndExtra_ = 0;      
    uint256 private rndGap_ = 0;          
    uint256 constant private rndInit_ = 12 hours;                 
    uint256 constant private rndInc_ = 30 seconds;               
    uint256 constant private rndMax_ = 24 hours;                 
    uint256 public airDropPot_;              
    uint256 public airDropTracker_ = 0;      
    uint256 public rID_;     
    uint256 public registrationFee_ = 10 finney;             
    mapping (address => uint256) public pIDxAddr_;           
    mapping (bytes32 => uint256) public pIDxName_;           
    mapping (uint256 => F3Ddatasets.Player) public plyr_;    
    mapping (uint256 => mapping (uint256 => F3Ddatasets.PlayerRounds)) public plyrRnds_;     
    uint256 private playerCount = 0;
    uint256 private totalWinnersKeys_;
    uint256 constant private winnerNum_ = 5;  
    function registerName(address _addr, bytes32 _name, uint256 _affCode) private returns(bool, uint256) {
        require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");
        require(pIDxName_[_name] == 0, "sorry that names already taken");
        uint256 _pID = pIDxAddr_[_addr];
        bool isNew = false;
        if (_pID == 0) {
            isNew = true;
            playerCount++;
            _pID = playerCount;
            pIDxAddr_[_addr] = _pID;
            plyr_[_pID].name = _name;
            pIDxName_[_name] = _pID;
        }
        if (_affCode != 0 && _affCode != plyr_[_pID].laff && _affCode != _pID) {
            plyr_[_pID].laff = _affCode;
        } else if (_affCode == _pID) {
            _affCode = 0;
        }
        return (isNew, _affCode);
    }
    function registerNameXaddrFromDapp(address _addr, bytes32 _name, address _affCode) private returns(bool, uint256) {
        uint256 _affID = 0;
        if (_affCode != address(0) && _affCode != _addr) {
            _affID = pIDxAddr_[_affCode];
        }
        return registerName(_addr, _name, _affID);
    }
    function registerNameXnameFromDapp(address _addr, bytes32 _name, bytes32 _affCode) private returns(bool, uint256) {
        uint256 _affID = 0;
        if (_affCode != "" && _affCode != _name) {
            _affID = pIDxName_[_affCode];
        }
        return registerName(_addr, _name, _affID);
    }
    mapping (uint256 => F3Ddatasets.Round) public round_;    
    mapping (uint256 => mapping(uint256 => uint256)) public rndTmEth_;       
    mapping (uint256 => F3Ddatasets.TeamFee) public fees_;           
    mapping (uint256 => F3Ddatasets.PotSplit) public potSplit_;      
    address owner;
    constructor()
        public
    {
        owner = msg.sender;
        fees_[0] = F3Ddatasets.TeamFee(30,12);
        fees_[1] = F3Ddatasets.TeamFee(43,7);
        fees_[2] = F3Ddatasets.TeamFee(52,16);
        fees_[3] = F3Ddatasets.TeamFee(43,15);
        potSplit_[0] = F3Ddatasets.PotSplit(15,15);
        potSplit_[1] = F3Ddatasets.PotSplit(25,10);
        potSplit_[2] = F3Ddatasets.PotSplit(20,24);
        potSplit_[3] = F3Ddatasets.PotSplit(30,14);
    }
    modifier isActivated() {
        require(activated_ == true, "its not ready yet.  check ?eta in discord"); 
        _;
    }
    modifier isOwner() {
        require(owner == msg.sender, "sorry owner only");
        _;
    }
    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;
        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }
    modifier isWithinLimits(uint256 _eth) {
        require(_eth >= 1000000000, "pocket lint: not a valid currency");
        require(_eth <= 100000000000000000000000, "no vitalik, no");
        _;    
    }
    function()
        isActivated()
        isHuman()
        isWithinLimits(msg.value)
        public
        payable
    {
        F3Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);
        uint256 _pID = pIDxAddr_[msg.sender];
        buyCore(_pID, plyr_[_pID].laff, 2, _eventData_);
    }
    function updateContract(address newContract) isOwner() public returns (bool) {
        if (round_[rID_].end < now) {
            Fomo3dContract nc = Fomo3dContract(newContract);
            newContract.transfer(address(this).balance);
            nc.setOldContractData(address(this));
            return (true);
        }
        return (false);
    }
    function buyXid(uint256 _affCode, uint256 _team)
        isActivated()
        isHuman()
        isWithinLimits(msg.value)
        public
        payable
    {
        F3Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);
        uint256 _pID = pIDxAddr_[msg.sender];
        if (_affCode == 0 || _affCode == _pID)
        {
            _affCode = plyr_[_pID].laff;
        } else if (_affCode != plyr_[_pID].laff) {
            plyr_[_pID].laff = _affCode;
        }
        _team = verifyTeam(_team);
        buyCore(_pID, _affCode, _team, _eventData_);
    }
    function buyXaddr(address _affCode, uint256 _team)
        isActivated()
        isHuman()
        isWithinLimits(msg.value)
        public
        payable
    {
        F3Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);
        uint256 _pID = pIDxAddr_[msg.sender];
        uint256 _affID;
        if (_affCode == address(0) || _affCode == msg.sender)
        {
            _affID = plyr_[_pID].laff;
        } else {
            _affID = pIDxAddr_[_affCode];
            if (_affID != plyr_[_pID].laff)
            {
                plyr_[_pID].laff = _affID;
            }
        }
        _team = verifyTeam(_team);
        buyCore(_pID, _affID, _team, _eventData_);
    }
    function buyXname(bytes32 _affCode, uint256 _team)
        isActivated()
        isHuman()
        isWithinLimits(msg.value)
        public
        payable
    {
        F3Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);
        uint256 _pID = pIDxAddr_[msg.sender];
        uint256 _affID;
        if (_affCode == "" || _affCode == plyr_[_pID].name)
        {
            _affID = plyr_[_pID].laff;
        } else {
            _affID = pIDxName_[_affCode];
            if (_affID != plyr_[_pID].laff)
            {
                plyr_[_pID].laff = _affID;
            }
        }
        _team = verifyTeam(_team);
        buyCore(_pID, _affID, _team, _eventData_);
    }
    function reLoadXid(uint256 _affCode, uint256 _team, uint256 _eth)
        isActivated()
        isHuman()
        isWithinLimits(_eth)
        public
    {
        F3Ddatasets.EventReturns memory _eventData_;
        uint256 _pID = pIDxAddr_[msg.sender];
        if (_affCode == 0 || _affCode == _pID)
        {
            _affCode = plyr_[_pID].laff;
        } else if (_affCode != plyr_[_pID].laff) {
            plyr_[_pID].laff = _affCode;
        }
        _team = verifyTeam(_team);
        reLoadCore(_pID, _affCode, _team, _eth, _eventData_);
    }
    function reLoadXaddr(address _affCode, uint256 _team, uint256 _eth)
        isActivated()
        isHuman()
        isWithinLimits(_eth)
        public
    {
        F3Ddatasets.EventReturns memory _eventData_;
        uint256 _pID = pIDxAddr_[msg.sender];
        uint256 _affID;
        if (_affCode == address(0) || _affCode == msg.sender)
        {
            _affID = plyr_[_pID].laff;
        } else {
            _affID = pIDxAddr_[_affCode];
            if (_affID != plyr_[_pID].laff)
            {
                plyr_[_pID].laff = _affID;
            }
        }
        _team = verifyTeam(_team);
        reLoadCore(_pID, _affID, _team, _eth, _eventData_);
    }
    function reLoadXname(bytes32 _affCode, uint256 _team, uint256 _eth)
        isActivated()
        isHuman()
        isWithinLimits(_eth)
        public
    {
        F3Ddatasets.EventReturns memory _eventData_;
        uint256 _pID = pIDxAddr_[msg.sender];
        uint256 _affID;
        if (_affCode == "" || _affCode == plyr_[_pID].name)
        {
            _affID = plyr_[_pID].laff;
        } else {
            _affID = pIDxName_[_affCode];
            if (_affID != plyr_[_pID].laff)
            {
                plyr_[_pID].laff = _affID;
            }
        }
        _team = verifyTeam(_team);
        reLoadCore(_pID, _affID, _team, _eth, _eventData_);
    }
    function withdraw()
        isActivated()
        isHuman()
        public
    {
        uint256 _rID = rID_;
        uint256 _now = now;
        uint256 _pID = pIDxAddr_[msg.sender];
        uint256 _eth;
        if (_now > round_[_rID].end && round_[_rID].ended == false && hasPlayersInRound(_rID) == true)
        {
            F3Ddatasets.EventReturns memory _eventData_;
            round_[_rID].ended = true;
            _eventData_ = endRound(_eventData_);
            _eth = withdrawEarnings(_pID);
            if (_eth > 0)
                plyr_[_pID].addr.transfer(_eth);    
            _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
            _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;
            emit F3Devents.onWithdrawAndDistribute
            (
                msg.sender, 
                plyr_[_pID].name, 
                _eth, 
                _eventData_.compressedData, 
                _eventData_.compressedIDs, 
                _eventData_.winnerAddr, 
                _eventData_.winnerName, 
                _eventData_.amountWon, 
                _eventData_.newPot, 
                _eventData_.P3DAmount, 
                _eventData_.genAmount
            );
        } else {
            _eth = withdrawEarnings(_pID);
            if (_eth > 0)
                plyr_[_pID].addr.transfer(_eth);
            emit F3Devents.onWithdraw(_pID, msg.sender, plyr_[_pID].name, _eth, _now);
        }
    }
    function registerNameXID(string _nameString, uint256 _affCode)
        isHuman()
        public
        payable
    {
        bytes32 _name = _nameString.nameFilter();
        address _addr = msg.sender;
        uint256 _paid = msg.value;
        (bool _isNewPlayer, uint256 _affID) = registerName(_addr, _name, _affCode);
        uint256 _pID = pIDxAddr_[_addr];
        emit F3Devents.onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, _paid, now);
    }
    function registerNameXaddr(string _nameString, address _affCode)
        isHuman()
        public
        payable
    {
        bytes32 _name = _nameString.nameFilter();
        address _addr = msg.sender;
        uint256 _paid = msg.value;
        (bool _isNewPlayer, uint256 _affID) = registerNameXaddrFromDapp(msg.sender, _name, _affCode);
        uint256 _pID = pIDxAddr_[_addr];
        emit F3Devents.onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, _paid, now);
    }
    function registerNameXname(string _nameString, bytes32 _affCode)
        isHuman()
        public
        payable
    {
        bytes32 _name = _nameString.nameFilter();
        address _addr = msg.sender;
        uint256 _paid = msg.value;
        (bool _isNewPlayer, uint256 _affID) = registerNameXnameFromDapp(msg.sender, _name, _affCode);
        uint256 _pID = pIDxAddr_[_addr];
        emit F3Devents.onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, _paid, now);
    }
    function getBuyPrice()
        public 
        view 
        returns(uint256)
    {  
        uint256 _rID = rID_;
        uint256 _now = now;
        if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && hasPlayersInRound(_rID) == false)))
            return ( (round_[_rID].keys.add(1000000000000000000)).ethRec(1000000000000000000) );
        else  
            return ( 75000000000000 );  
    }
    function getTimeLeft()
        public
        view
        returns(uint256)
    {
        uint256 _rID = rID_;
        uint256 _now = now;
        if (_now < round_[_rID].end)
            if (_now > round_[_rID].strt + rndGap_)
                return( (round_[_rID].end).sub(_now) );
            else
                return( (round_[_rID].strt + rndGap_).sub(_now) );
        else
            return(0);
    }
    function isWinner(uint256 _pID, uint256 _rID) private view returns (bool) {
        for (uint8 i = 0; i < winnerNum_; i++) {
            if (round_[_rID].plyrs[i] == _pID) {
                return (true);
            }
        }
        return (false);
    }
    function getPlayerVaults(uint256 _pID)
        public
        view
        returns(uint256 ,uint256, uint256)
    {
        uint256 _rID = rID_;
        if (now > round_[_rID].end && round_[_rID].ended == false && hasPlayersInRound(_rID) == true)
        {
            if (isWinner(_pID, _rID))
            {
                calcTotalWinnerKeys(_rID);
                return
                (
                    (plyr_[_pID].win).add( (((round_[_rID].pot).mul(48)) / 100).mul(plyrRnds_[_pID][_rID].keys) / totalWinnersKeys_ ),
                    (plyr_[_pID].gen).add(  getPlayerVaultsHelper(_pID, _rID).sub(plyrRnds_[_pID][_rID].mask)   ),
                    plyr_[_pID].aff
                );
            } else {
                return
                (
                    plyr_[_pID].win,
                    (plyr_[_pID].gen).add(  getPlayerVaultsHelper(_pID, _rID).sub(plyrRnds_[_pID][_rID].mask)  ),
                    plyr_[_pID].aff
                );
            }
        } else {
            return
            (
                plyr_[_pID].win,
                (plyr_[_pID].gen).add(calcUnMaskedEarnings(_pID, plyr_[_pID].lrnd)),
                plyr_[_pID].aff
            );
        }
    }
    function getPlayerVaultsHelper(uint256 _pID, uint256 _rID)
        private
        view
        returns(uint256)
    {
        return(  ((((round_[_rID].mask).add(((((round_[_rID].pot).mul(potSplit_[round_[_rID].team].gen)) / 100).mul(1000000000000000000)) / (round_[_rID].keys))).mul(plyrRnds_[_pID][_rID].keys)) / 1000000000000000000)  );
    }
    function getCurrentRoundInfo()
        public
        view
        returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, address, bytes32, uint256, uint256, uint256, uint256, uint256)
    {
        return
        (
            round_[rID_].ico,                
            rID_,                            
            round_[rID_].keys,               
            round_[rID_].end,                
            round_[rID_].strt,               
            round_[rID_].pot,                
            (round_[rID_].team + (round_[rID_].plyrs[winnerNum_ - 1] * 10)),      
            plyr_[round_[rID_].plyrs[winnerNum_ - 1]].addr,   
            plyr_[round_[rID_].plyrs[winnerNum_ - 1]].name,   
            rndTmEth_[rID_][0],              
            rndTmEth_[rID_][1],              
            rndTmEth_[rID_][2],              
            rndTmEth_[rID_][3],              
            airDropTracker_ + (airDropPot_ * 1000)               
        );
    }
    function getPlayerInfoByAddress(address _addr)
        public 
        view 
        returns(uint256, bytes32, uint256, uint256, uint256, uint256, uint256)
    {
        uint256 _rID = rID_;
        if (_addr == address(0))
        {
            _addr == msg.sender;
        }
        uint256 _pID = pIDxAddr_[_addr];
        return
        (
            _pID,                                
            plyr_[_pID].name,                    
            plyrRnds_[_pID][_rID].keys,          
            plyr_[_pID].win,                     
            (plyr_[_pID].gen).add(calcUnMaskedEarnings(_pID, plyr_[_pID].lrnd)),        
            plyr_[_pID].aff,                     
            plyrRnds_[_pID][_rID].eth            
        );
    }
    function hasPlayersInRound(uint256 _rID) private view returns (bool){
        for (uint8 i = 0; i < round_[_rID].plyrs.length; i++) {
            if (round_[_rID].plyrs[i] != 0) {
                return (true);
            }
        }
        return (false);
    }
    function buyCore(uint256 _pID, uint256 _affID, uint256 _team, F3Ddatasets.EventReturns memory _eventData_)
        private
    {
        uint256 _rID = rID_;
        uint256 _now = now;
        if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && hasPlayersInRound(_rID) == false))) 
        {
            core(_rID, _pID, msg.value, _affID, _team, _eventData_);
        } else {
            if (_now > round_[_rID].end && round_[_rID].ended == false) 
            {
                round_[_rID].ended = true;
                _eventData_ = endRound(_eventData_);
                _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
                _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;
                emit F3Devents.onBuyAndDistribute
                (
                    msg.sender, 
                    plyr_[_pID].name, 
                    msg.value, 
                    _eventData_.compressedData, 
                    _eventData_.compressedIDs, 
                    _eventData_.winnerAddr, 
                    _eventData_.winnerName, 
                    _eventData_.amountWon, 
                    _eventData_.newPot, 
                    _eventData_.P3DAmount, 
                    _eventData_.genAmount
                );
            }
            plyr_[_pID].gen = plyr_[_pID].gen.add(msg.value);
        }
    }
    function reLoadCore(uint256 _pID, uint256 _affID, uint256 _team, uint256 _eth, F3Ddatasets.EventReturns memory _eventData_)
        private
    {
        uint256 _rID = rID_;
        uint256 _now = now;
        if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && hasPlayersInRound(_rID) == false))) 
        {
            plyr_[_pID].gen = withdrawEarnings(_pID).sub(_eth);
            core(_rID, _pID, _eth, _affID, _team, _eventData_);
        } else if (_now > round_[_rID].end && round_[_rID].ended == false) {
            round_[_rID].ended = true;
            _eventData_ = endRound(_eventData_);
            _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
            _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;
            emit F3Devents.onReLoadAndDistribute
            (
                msg.sender, 
                plyr_[_pID].name, 
                _eventData_.compressedData, 
                _eventData_.compressedIDs, 
                _eventData_.winnerAddr, 
                _eventData_.winnerName, 
                _eventData_.amountWon, 
                _eventData_.newPot, 
                _eventData_.P3DAmount, 
                _eventData_.genAmount
            );
        }
    }
    function contains(uint256 _pID, uint256[winnerNum_] memory array) private pure returns (bool) {
        for (uint8 i = 0; i < array.length; i++) {
            if (array[i] == _pID) {
                return (true);
            }
        }
        return (false);
    }
    function calcTotalWinnerKeys(uint256 _rID) private {
        uint256[winnerNum_] memory winnerPIDs;
        totalWinnersKeys_ = 0;
        for (uint8 i = 0; i < winnerNum_; i++) {
            if (!contains(round_[_rID].plyrs[i], winnerPIDs)) {
                winnerPIDs[i] = round_[_rID].plyrs[i];
                totalWinnersKeys_ = totalWinnersKeys_.add(plyrRnds_[round_[_rID].plyrs[i]][_rID].keys);
            }
        }
    }
    function core(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, F3Ddatasets.EventReturns memory _eventData_)
        private
    {
        if (plyrRnds_[_pID][_rID].keys == 0)
            _eventData_ = managePlayer(_pID, _eventData_);
        if (round_[_rID].eth < (100 ether) && plyrRnds_[_pID][_rID].eth.add(_eth) > (1 ether))
        {
            uint256 _availableLimit = (1 ether).sub(plyrRnds_[_pID][_rID].eth);
            uint256 _refund = _eth.sub(_availableLimit);
            plyr_[_pID].gen = plyr_[_pID].gen.add(_refund);
            _eth = _availableLimit;
        }
        if (_eth > 1000000000) 
        {
            uint256 _keys = (round_[_rID].eth).keysRec(_eth);
            if (_keys >= 1000000000000000000)
            {
                updateTimer(_keys, _rID);
                round_[_rID].plyrs[0] = round_[_rID].plyrs[1];
                round_[_rID].plyrs[1] = round_[_rID].plyrs[2];
                round_[_rID].plyrs[2] = round_[_rID].plyrs[3];
                round_[_rID].plyrs[3] = round_[_rID].plyrs[4];
                round_[_rID].plyrs[4] = _pID;
                if (round_[_rID].team != _team) {
                    round_[_rID].team = _team; 
                }
                _eventData_.compressedData = _eventData_.compressedData + 100;
            }
            if (_eth >= 100000000000000000)
            {
                airDropTracker_++;
                if (airdrop() == true)
                {
                    uint256 _prize;
                    if (_eth >= 10000000000000000000)
                    {
                        _prize = ((airDropPot_).mul(75)) / 100;
                        plyr_[_pID].win = (plyr_[_pID].win).add(_prize);
                        airDropPot_ = (airDropPot_).sub(_prize);
                        _eventData_.compressedData += 300000000000000000000000000000000;
                    } else if (_eth >= 1000000000000000000 && _eth < 10000000000000000000) {
                        _prize = ((airDropPot_).mul(50)) / 100;
                        plyr_[_pID].win = (plyr_[_pID].win).add(_prize);
                        airDropPot_ = (airDropPot_).sub(_prize);
                        _eventData_.compressedData += 200000000000000000000000000000000;
                    } else if (_eth >= 100000000000000000 && _eth < 1000000000000000000) {
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
    function calcUnMaskedEarnings(uint256 _pID, uint256 _rIDlast)
        private
        view
        returns(uint256)
    {
        return(  (((round_[_rIDlast].mask).mul(plyrRnds_[_pID][_rIDlast].keys)) / (1000000000000000000)).sub(plyrRnds_[_pID][_rIDlast].mask)  );
    }
    function calcKeysReceived(uint256 _rID, uint256 _eth)
        public
        view
        returns(uint256)
    {
        uint256 _now = now;
        if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && hasPlayersInRound(_rID) == false)))
            return ( (round_[_rID].eth).keysRec(_eth) );
        else  
            return ( (_eth).keys() );
    }
    function iWantXKeys(uint256 _keys)
        public
        view
        returns(uint256)
    {
        uint256 _rID = rID_;
        uint256 _now = now;
        if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && hasPlayersInRound(_rID) == false)))
            return ( (round_[_rID].keys.add(_keys)).ethRec(_keys) );
        else  
            return ( (_keys).eth() );
    }
    function determinePID(F3Ddatasets.EventReturns memory _eventData_)
        private
        returns (F3Ddatasets.EventReturns)
    {
        uint256 _pID = pIDxAddr_[msg.sender];
        if (_pID == 0)
        {
            playerCount++;
            _pID = playerCount;
            bytes32 _name = plyr_[_pID].name;
            uint256 _laff = plyr_[_pID].laff;
            pIDxAddr_[msg.sender] = _pID;
            plyr_[_pID].addr = msg.sender;
            if (_name != "")
            {
                pIDxName_[_name] = _pID;
                plyr_[_pID].name = _name;
            }
            if (_laff != 0 && _laff != _pID)
                plyr_[_pID].laff = _laff;
            _eventData_.compressedData = _eventData_.compressedData + 1;
        } 
        return (_eventData_);
    }
    function verifyTeam(uint256 _team)
        private
        pure
        returns (uint256)
    {
        if (_team < 0 || _team > 3)
            return(2);
        else
            return(_team);
    }
    function managePlayer(uint256 _pID, F3Ddatasets.EventReturns memory _eventData_)
        private
        returns (F3Ddatasets.EventReturns)
    {
        if (plyr_[_pID].lrnd != 0)
            updateGenVault(_pID, plyr_[_pID].lrnd);
        plyr_[_pID].lrnd = rID_;
        _eventData_.compressedData = _eventData_.compressedData + 10;
        return(_eventData_);
    }
    function endRound(F3Ddatasets.EventReturns memory _eventData_)
        private
        returns (F3Ddatasets.EventReturns)
    {
        uint256 _rID = rID_;
        uint256 _win = ((round_[_rID].pot).mul(48)) / 100;
        uint256 _gen = ((round_[_rID].pot).mul(potSplit_[round_[_rID].team].gen)) / 100;
        uint256 _fee = ((round_[_rID].pot) / 50).add(((round_[_rID].pot).mul(potSplit_[round_[_rID].team].p3d)) / 100);
        uint256 _res = ((((round_[_rID].pot).sub(_win)).sub(_fee)).sub(_gen));
        uint256 _ppt = (_gen.mul(1000000000000000000)) / (round_[_rID].keys);
        uint256 _dust = _gen.sub((_ppt.mul(round_[_rID].keys)) / 1000000000000000000);
        if (_dust > 0)
        {
            _gen = _gen.sub(_dust);
            _res = _res.add(_dust);
        }
        calcTotalWinnerKeys(_rID);
        plyr_[round_[_rID].plyrs[winnerNum_ - 1]].win = (_win.mul(plyrRnds_[round_[_rID].plyrs[winnerNum_ - 1]][_rID].keys) / totalWinnersKeys_).add(plyr_[round_[_rID].plyrs[winnerNum_ - 1]].win);
        for (uint8 i = 0; i < winnerNum_ - 1; i++) {
            plyr_[round_[_rID].plyrs[i]].win = (_win.mul(plyrRnds_[round_[_rID].plyrs[i]][_rID].keys) / totalWinnersKeys_).add(plyr_[round_[_rID].plyrs[i]].win);
        }
        round_[_rID].mask = _ppt.add(round_[_rID].mask);
        if (!teamAddress.send(_fee)) {
        }
        _eventData_.compressedData = _eventData_.compressedData + (round_[_rID].end * 1000000);
        _eventData_.compressedIDs = _eventData_.compressedIDs + (round_[_rID].plyrs[winnerNum_ - 1] * 100000000000000000000000000) + (round_[_rID].team * 100000000000000000);
        _eventData_.winnerAddr = plyr_[round_[_rID].plyrs[winnerNum_ - 1]].addr;
        _eventData_.winnerName = plyr_[round_[_rID].plyrs[winnerNum_ - 1]].name;
        _eventData_.amountWon = _win;
        _eventData_.genAmount = _gen;
        _eventData_.P3DAmount = ((round_[_rID].pot).mul(potSplit_[round_[_rID].team].p3d)) / 100;
        _eventData_.newPot = _res;
        rID_++;
        _rID++;
        round_[_rID].strt = now;
        round_[_rID].end = now.add(rndInit_).add(rndGap_);
        round_[_rID].pot = _res;
        return(_eventData_);
    }
    function updateGenVault(uint256 _pID, uint256 _rIDlast)
        private 
    {
        uint256 _earnings = calcUnMaskedEarnings(_pID, _rIDlast);
        if (_earnings > 0)
        {
            plyr_[_pID].gen = _earnings.add(plyr_[_pID].gen);
            plyrRnds_[_pID][_rIDlast].mask = _earnings.add(plyrRnds_[_pID][_rIDlast].mask);
        }
    }
    function updateTimer(uint256 _keys, uint256 _rID)
        private
    {
        uint256 _now = now;
        uint256 _newTime;
        if (_now > round_[_rID].end && hasPlayersInRound(_rID) == false)
            _newTime = (((_keys) / (1000000000000000000)).mul(rndInc_)).add(_now);
        else
            _newTime = (((_keys) / (1000000000000000000)).mul(rndInc_)).add(round_[_rID].end);
        uint256 _rndEth = round_[_rID].eth;  
        uint256 _rndNeedSub = 0;  
        if (_rndEth >= (2000 ether)) {
            if (_rndEth <= (46000 ether)) {  
                _rndNeedSub = (1 hours).mul(_rndEth / (2000 ether));
            } else {
                _rndNeedSub = (1 hours).mul(23);
                uint256 _ethLeft = _rndEth.sub(46000 ether);
                if (_ethLeft <= (12000 ether)) {
                    _rndNeedSub = _rndNeedSub.add((590 seconds).mul(_ethLeft / (2000 ether)));
                } else {  
                    _rndNeedSub = 999;
                }
            }
        }
        if (_rndNeedSub != 999) {
            uint256 _rndMax = rndMax_.sub(_rndNeedSub);
            if (_newTime < (_rndMax).add(_now))
                round_[_rID].end = _newTime;
            else
                round_[_rID].end = _rndMax.add(_now);
        }
    }
    function airdrop()
        private 
        view 
        returns(bool)
    {
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
    function distributeExternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, F3Ddatasets.EventReturns memory _eventData_)
        private
        returns(F3Ddatasets.EventReturns)
    {
        uint256 _com = _eth / 50;
        uint256 _p3d;
        uint256 _long = _eth / 100;
        uint256 _aff = _eth / 10;
        if (_affID != _pID && plyr_[_affID].name != "") {
            plyr_[_affID].aff = _aff.add(plyr_[_affID].aff);
            emit F3Devents.onAffiliatePayout(_affID, plyr_[_affID].addr, plyr_[_affID].name, _rID, _pID, _aff, now);
        } else {
            _p3d = _aff;
        }
        _p3d = _p3d.add((_eth.mul(fees_[_team].p3d)) / (100));
        if (_p3d > 0)
        {   
            _eventData_.P3DAmount = _p3d.add(_eventData_.P3DAmount);
        }
        if (!teamAddress.send(_p3d.add(_com).add(_long))) {
        }
        return(_eventData_);
    }
    function potSwap()
        external
        payable
    {
        uint256 _rID = rID_ + 1;
        round_[_rID].pot = round_[_rID].pot.add(msg.value);
        emit F3Devents.onPotSwapDeposit(_rID, msg.value);
    }
    function distributeInternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _team, uint256 _keys, F3Ddatasets.EventReturns memory _eventData_)
        private
        returns(F3Ddatasets.EventReturns)
    {
        uint256 _gen = (_eth.mul(fees_[_team].gen)) / 100;
        uint256 _air = (_eth / 100);
        airDropPot_ = airDropPot_.add(_air);
        _eth = _eth.sub(((_eth.mul(14)) / 100).add((_eth.mul(fees_[_team].p3d)) / 100));
        uint256 _pot = _eth.sub(_gen);
        uint256 _dust = updateMasks(_rID, _pID, _gen, _keys);
        if (_dust > 0)
            _gen = _gen.sub(_dust);
        round_[_rID].pot = _pot.add(_dust).add(round_[_rID].pot);
        _eventData_.genAmount = _gen.add(_eventData_.genAmount);
        _eventData_.potAmount = _pot;
        return(_eventData_);
    }
    function updateMasks(uint256 _rID, uint256 _pID, uint256 _gen, uint256 _keys)
        private
        returns(uint256)
    {
        uint256 _ppt = (_gen.mul(1000000000000000000)) / (round_[_rID].keys);
        round_[_rID].mask = _ppt.add(round_[_rID].mask);
        uint256 _pearn = (_ppt.mul(_keys)) / (1000000000000000000);
        plyrRnds_[_pID][_rID].mask = (((round_[_rID].mask.mul(_keys)) / (1000000000000000000)).sub(_pearn)).add(plyrRnds_[_pID][_rID].mask);
        return(_gen.sub((_ppt.mul(round_[_rID].keys)) / (1000000000000000000)));
    }
    function withdrawEarnings(uint256 _pID)
        private
        returns(uint256)
    {
        updateGenVault(_pID, plyr_[_pID].lrnd);
        uint256 _earnings = (plyr_[_pID].win).add(plyr_[_pID].gen).add(plyr_[_pID].aff);
        if (_earnings > 0)
        {
            plyr_[_pID].win = 0;
            plyr_[_pID].gen = 0;
            plyr_[_pID].aff = 0;
        }
        return(_earnings);
    }
    function endTx(uint256 _pID, uint256 _team, uint256 _eth, uint256 _keys, F3Ddatasets.EventReturns memory _eventData_)
        private
    {
        _eventData_.compressedData = _eventData_.compressedData + (now * 1000000000000000000) + (_team * 100000000000000000000000000000);
        _eventData_.compressedIDs = _eventData_.compressedIDs + _pID + (rID_ * 10000000000000000000000000000000000000000000000000000);
        emit F3Devents.onEndTx
        (
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
            _eventData_.P3DAmount,
            _eventData_.genAmount,
            _eventData_.potAmount,
            airDropPot_
        );
    }
    bool public activated_ = false;
    function activate()
        isOwner()
        public
    {
        require(activated_ == false, "fomo3d already activated");
        activated_ = true;
        rID_ = 1;
        round_[1].strt = now + rndExtra_ - rndGap_;
        round_[1].end = now + rndInit_ + rndExtra_;
    }
}
