contract FoMo3Dlong is modularLong {
    using SafeMath for *;
    using NameFilter for string;
    using F3DKeysCalcLong for uint256;
    address constant private god = 0xe1B35fEBaB9Ff6da5b29C3A7A44eef06cD86B0f9;
    PlayerBookInterface constant private PlayerBook = PlayerBookInterface(0xf79341b38865310e1a00d7630bd1decc92a8f8b1);
    string constant public name = "FM3D Pyramid Selling Heihei~";
    string constant public symbol = "F3D";
    uint256 private rndExtra_ = 0 minutes;                      
    uint256 private rndGap_ = 0 minutes;                        
    uint256 constant private rndInit_ = 1 hours;                 
    uint256 constant private rndInc_ = 30 seconds;               
    uint256 constant private rndMax_ = 24 hours;                 
    uint256[3] private potToWinners_ = [30,15,10];               
    uint256 constant private potToMaxEth_ = 20;                  
    uint256 constant private potToMaxAff_ = 20;                  
    uint256 public airDropPot_;              
    uint256 public airDropTracker_ = 0;      
    uint256 public rID_;     
    mapping (address => uint256) public pIDxAddr_;           
    mapping (bytes32 => uint256) public pIDxName_;           
    mapping (uint256 => F3Ddatasets.Player) public plyr_;    
    mapping (uint256 => mapping (uint256 => F3Ddatasets.PlayerRounds)) public plyrRnds_;     
    mapping (uint256 => mapping (bytes32 => bool)) public plyrNames_;  
    mapping (uint256 => F3Ddatasets.Round) public round_;    
    mapping (uint256 => mapping(uint256 => uint256)) public rndTmEth_;       
    uint256[3] private affPerLv_ = [20,10,5];   
    constructor()
        public
    {
    }
    modifier isActivated() {
        require(activated_ == true, "its not ready yet.  check ?eta in discord"); 
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
    function determineAffID(uint256 _pID, uint256 _inAffID) private returns(uint256){
        if(plyr_[_pID].laff == 0 && 0 != _inAffID && _pID != _inAffID && plyr_[_inAffID].name != ''){
            plyr_[_pID].laff = _inAffID;
            uint256 _rID = (0 == rID_)?1:rID_;
            plyrRnds_[_rID][_inAffID].affNum =  plyrRnds_[_rID][_inAffID].affNum.add(1);
            if( plyrRnds_[_rID][round_[_rID].maxAffPID].affNum < plyrRnds_[_rID][_inAffID].affNum){
                round_[_rID].maxAffPID = _inAffID;
            }
        }
        return plyr_[_pID].laff;
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
        _affCode = determineAffID(_pID,_affCode);
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
        uint256 _affID = determineAffID(_pID,pIDxAddr_[_affCode]);
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
        uint256 _affID = determineAffID(_pID,pIDxName_[_affCode]);
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
        _affCode = determineAffID(_pID,_affCode);
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
        uint256 _affID = determineAffID(_pID,pIDxAddr_[_affCode]);
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
        uint256 _affID = determineAffID(_pID,pIDxName_[_affCode]);
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
        if (_now > round_[_rID].end && round_[_rID].ended == false && round_[_rID].plyr != 0)
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
    function registerNameXID(string _nameString, uint256 _affCode, bool _all)
        isHuman()
        public
        payable
    {
        bytes32 _name = _nameString.nameFilter();
        address _addr = msg.sender;
        uint256 _paid = msg.value;
        (bool _isNewPlayer, uint256 _affID) = PlayerBook.registerNameXIDFromDapp.value(_paid)(_addr, _name, _affCode, _all);
        uint256 _pID = pIDxAddr_[_addr];
        emit F3Devents.onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, _paid, now);
    }
    function registerNameXaddr(string _nameString, address _affCode, bool _all)
        isHuman()
        public
        payable
    {
        bytes32 _name = _nameString.nameFilter();
        address _addr = msg.sender;
        uint256 _paid = msg.value;
        (bool _isNewPlayer, uint256 _affID) = PlayerBook.registerNameXaddrFromDapp.value(msg.value)(msg.sender, _name, _affCode, _all);
        uint256 _pID = pIDxAddr_[_addr];
        emit F3Devents.onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, _paid, now);
    }
    function registerNameXname(string _nameString, bytes32 _affCode, bool _all)
        isHuman()
        public
        payable
    {
        bytes32 _name = _nameString.nameFilter();
        address _addr = msg.sender;
        uint256 _paid = msg.value;
        (bool _isNewPlayer, uint256 _affID) = PlayerBook.registerNameXnameFromDapp.value(msg.value)(msg.sender, _name, _affCode, _all);
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
        if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
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
    function getPlayerVaults(uint256 _pID)
        public
        view
        returns(uint256 ,uint256, uint256)
    {
        uint256 _rID = rID_;
        if (now > round_[_rID].end && round_[_rID].ended == false && round_[_rID].plyr != 0)
        {
            if (round_[_rID].plyr == _pID)
            {
                return
                (
                    (plyr_[_pID].win).add( ((round_[_rID].pot).mul(48)) / 100 ),
                    (plyr_[_pID].gen), 
                    plyr_[_pID].aff
                );
            } else {
                return
                (
                    plyr_[_pID].win,
                    (plyr_[_pID].gen), 
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
        return(  ((((round_[_rID].mask).add(((((round_[_rID].pot).mul(0)) / 100).mul(1000000000000000000)) / (round_[_rID].keys))).mul(plyrRnds_[_pID][_rID].keys)) / 1000000000000000000)  );
    }
    function getCurrentRoundInfo()
        public
        view
        returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, address, bytes32, uint256, uint256, uint256, uint256, uint256)
    {
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
    function getCurrentRoundInfo2()
        public
        view
        returns(bytes32, uint256, bytes32, uint256, bytes32, bytes32, bytes32)
    {
        uint256 _rID = rID_;
        return 
        (
            plyr_[round_[_rID].maxEthPID].name,  
            plyrRnds_[round_[_rID].maxEthPID][_rID].eth,   
            plyr_[round_[_rID].maxAffPID].name,  
            plyrRnds_[round_[_rID].maxAffPID][_rID].affNum,  
            plyr_[round_[_rID].plyrs[0]].name,   
            plyr_[round_[_rID].plyrs[1]].name,   
            plyr_[round_[_rID].plyrs[2]].name    
        );
    }
    function getPlayerInfoByAddress(address _addr)
        public 
        view 
        returns(uint256, bytes32, uint256, uint256, uint256, uint256, uint256, bytes32)
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
            plyrRnds_[_pID][_rID].eth,           
            plyr_[plyr_[_pID].laff].name         
        );
    }
    function buyCore(uint256 _pID, uint256 _affID, uint256 _team, F3Ddatasets.EventReturns memory _eventData_)
        private
    {
        uint256 _rID = rID_;
        uint256 _now = now;
        if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0))) 
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
        if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0))) 
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
    function updateLastBuyKeysPIDs(uint256 _rID, uint256 _lastPID)
        private 
    {
        for(uint256 _i=potToWinners_.length-1; _i>=1; _i--){
            round_[_rID].plyrs[_i] = round_[_rID].plyrs[_i - 1];
        }
        round_[_rID].plyrs[0] = _lastPID;
    }
    function core(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, F3Ddatasets.EventReturns memory _eventData_)
        private
    {
        if (plyrRnds_[_pID][_rID].keys == 0)
            _eventData_ = managePlayer(_pID, _eventData_);
        if (_eth > 1000000000) 
        {
            uint256 _keys = (round_[_rID].eth).keysRec(_eth);
            if (_keys >= 1000000000000000000)
            {
                updateTimer(_keys, _rID);
                if(_eth > 10000000000000000){
                    if (round_[_rID].plyr != _pID){
                        round_[_rID].plyr = _pID;
                    }
                    updateLastBuyKeysPIDs(_rID, _pID);
                }
                if (round_[_rID].team != _team){ round_[_rID].team = _team; } 
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
            if(0 == round_[_rID].maxEthPID || plyrRnds_[round_[_rID].maxEthPID][_rID].eth < plyrRnds_[_pID][_rID].eth){
                round_[_rID].maxEthPID = _pID;
            }
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
        if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
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
        if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
            return ( (round_[_rID].keys.add(_keys)).ethRec(_keys) );
        else  
            return ( (_keys).eth() );
    }
    function receivePlayerInfo(uint256 _pID, address _addr, bytes32 _name, uint256 _laff)
        external
    {
        require (msg.sender == address(PlayerBook), "your not playerNames contract... hmmm..");
        if (pIDxAddr_[_addr] != _pID){ pIDxAddr_[_addr] = _pID; }
        if (pIDxName_[_name] != _pID){ pIDxName_[_name] = _pID; }
        if (plyr_[_pID].addr != _addr){ plyr_[_pID].addr = _addr; }
        if (plyr_[_pID].name != _name){ plyr_[_pID].name = _name; }
        if (plyr_[_pID].laff != _laff){ determineAffID(_pID, _laff); }
        if (plyrNames_[_pID][_name] == false){ plyrNames_[_pID][_name] = true; }
    }
    function receivePlayerNameList(uint256 _pID, bytes32 _name)
        external
    {
        require (msg.sender == address(PlayerBook), "your not playerNames contract... hmmm..");
        if(plyrNames_[_pID][_name] == false)
            plyrNames_[_pID][_name] = true;
    }   
    function determinePID(F3Ddatasets.EventReturns memory _eventData_)
        private
        returns (F3Ddatasets.EventReturns)
    {
        uint256 _pID = pIDxAddr_[msg.sender];
        if (_pID == 0)
        {
            _pID = PlayerBook.getPlayerID(msg.sender);
            bytes32 _name = PlayerBook.getPlayerName(_pID);
            uint256 _laff = PlayerBook.getPlayerLAff(_pID);
            pIDxAddr_[msg.sender] = _pID;
            plyr_[_pID].addr = msg.sender;
            if (_name != "")
            {
                pIDxName_[_name] = _pID;
                plyr_[_pID].name = _name;
                plyrNames_[_pID][_name] = true;
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
        uint256 _winTID = round_[_rID].team;
        uint256 _maxEthPID = round_[_rID].maxEthPID;
        uint256 _maxAffPID = round_[_rID].maxAffPID;
        if(0 == _maxAffPID){ _maxAffPID = 1; }
        uint256 _pot = round_[_rID].pot;
        uint256 _maxEth = (_pot.mul(potToMaxEth_)) / 100;
        uint256 _maxAff = (_pot.mul(potToMaxAff_)) / 100;
        uint256 _res = _pot.sub(_win).sub(_maxEth);
        plyr_[_maxEthPID].win = _maxEth.add(plyr_[_maxEthPID].win);
        plyr_[_maxAffPID].win = _maxAff.add(plyr_[_maxAffPID].win);
        for(uint256 _seq=0; _seq<potToWinners_.length; _seq++){
            uint256 _win = _pot.mul(potToWinners_[_seq]) / 100;
            uint256 _winPID = round_[_rID].plyrs[_seq];
            if(0 == _winPID){
               _winPID = 1;
            }
            plyr_[_winPID].win = _win.add(plyr_[_winPID].win);
            _res = _res.sub(_win);
            emit F3Devents.onRoundEnded1(
                _seq,
                _winPID,
                _win
            );
        }
        emit F3Devents.onRoundEnded2(
            _maxEthPID,
            _maxEth,
            _maxAffPID,
            _maxAff
        );
        _eventData_.compressedData = _eventData_.compressedData + (round_[_rID].end * 1000000);
        _eventData_.compressedIDs = _eventData_.compressedIDs + (_winPID * 100000000000000000000000000) + (_winTID * 100000000000000000);
        _eventData_.winnerAddr = plyr_[_winPID].addr;
        _eventData_.winnerName = plyr_[_winPID].name;
        _eventData_.amountWon = _win;
        _eventData_.genAmount = 0;
        _eventData_.P3DAmount = 0;
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
    function getRealRndMaxTime(uint256 _rID)
        public
        returns(uint256)
    {
        uint256 _realRndMax = rndMax_;
        uint256 _days = (now - round_[_rID].strt) / (1 days);
        while(0 < _days --){
            _realRndMax = _realRndMax / 2;
        }
        return (_realRndMax > 10 minutes) ? _realRndMax : 10 minutes;
    }
    function updateTimer(uint256 _keys, uint256 _rID)
        private
    {
        uint256 _now = now;
        uint256 _newTime;
        if (_now > round_[_rID].end && round_[_rID].plyr == 0)
            _newTime = (((_keys) / (1000000000000000000)).mul(rndInc_)).add(_now);
        else
            _newTime = (((_keys) / (1000000000000000000)).mul(rndInc_)).add(round_[_rID].end);
        uint256 _realRndMax = getRealRndMaxTime(_rID);
        if (_newTime < (_realRndMax).add(_now))
            round_[_rID].end = _newTime;
        else
            round_[_rID].end = _realRndMax.add(_now);
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
        uint256 _com = _eth / 20;
        address(god).transfer(_com);
        uint256 _curAffID = plyr_[_pID].laff;
        for(uint256 _i=0; _i< affPerLv_.length; _i++){
            uint256 _aff =  _eth.mul(affPerLv_[_i]) / (100);
            if (_curAffID == _pID || plyr_[_curAffID].name == '') {
                _curAffID = 1;
            }
            plyr_[_curAffID].aff = _aff.add(plyr_[_curAffID].aff);
            emit F3Devents.onAffiliatePayout(_curAffID, plyr_[_curAffID].addr, plyr_[_curAffID].name, _rID, _pID, _aff, now);
            _curAffID = plyr_[_curAffID].laff;
        }
        return(_eventData_);
    }
    function distributeInternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _team, uint256 _keys, F3Ddatasets.EventReturns memory _eventData_)
        private
        returns(F3Ddatasets.EventReturns)
    {
        uint256 _gen = _eth.mul(40) / 100;
        uint256 _air = 0;  
        airDropPot_ = airDropPot_.add(_air);
        uint256 _pot = (_eth.mul(20)) / 100;  
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
        public
    {
        require(msg.sender == god, "only team just can activate");
        require(activated_ == false, "fomo3d already activated");
        activated_ = true;
		rID_ = 1;
        round_[1].strt = now + rndExtra_ - rndGap_;
        round_[1].end = now + rndInit_ + rndExtra_;
    }
}