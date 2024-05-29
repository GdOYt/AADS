contract PlayerBook {
    using NameFilter for string;
    using SafeMath for uint256;
    address private communityAddr = 0xf38ce89f0e7c0057fce8dc1e8dcbb36a2366e8c5;
    uint256 public registrationFee_ = 10 finney;             
    mapping(uint256 => PlayerBookReceiverInterface) public games_;   
    mapping(address => bytes32) public gameNames_;           
    mapping(address => uint256) public gameIDs_;             
    uint256 public gID_;         
    uint256 public pID_;         
    mapping (address => uint256) public pIDxAddr_;           
    mapping (bytes32 => uint256) public pIDxName_;           
    mapping (uint256 => Player) public plyr_;                
    mapping (uint256 => mapping (bytes32 => bool)) public plyrNames_;  
    mapping (uint256 => mapping (uint256 => bytes32)) public plyrNameList_;  
    struct Player {
        address addr;
        bytes32 name;
        uint256 laff;
        uint256 names;
    }
    constructor()
    public
    {
        plyr_[1].addr = 0xde38b17d669a1ca474f9adb4ca3c816e79275567;
        plyr_[1].name = "plyr1";
        plyr_[1].names = 1;
        pIDxAddr_[0xde38b17d669a1ca474f9adb4ca3c816e79275567] = 1;
        pIDxName_["plyr1"] = 1;
        plyrNames_[1]["plyr1"] = true;
        plyrNameList_[1][1] = "plyr1";
        plyr_[2].addr = 0x0fa923b59b06b757f37ddd36d6862ebb37733faa;
        plyr_[2].name = "plyr2";
        plyr_[2].names = 1;
        pIDxAddr_[0x0fa923b59b06b757f37ddd36d6862ebb37733faa] = 2;
        pIDxName_["plyr2"] = 2;
        plyrNames_[2]["plyr2"] = true;
        plyrNameList_[2][1] = "plyr2";
        pID_ = 2;
    }
    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;
        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }
    modifier onlyCommunity()
    {
        require(msg.sender == communityAddr, "msg sender is not the community");
        _;
    }
    modifier isRegisteredGame()
    {
        require(gameIDs_[msg.sender] != 0);
        _;
    }
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
    function checkIfNameValid(string _nameStr)
    public
    view
    returns(bool)
    {
        bytes32 _name = _nameStr.nameFilter();
        if (pIDxName_[_name] == 0)
            return (true);
        else
            return (false);
    }
    function registerNameXID(string _nameString, uint256 _affCode, bool _all)
    isHuman()
    public
    payable
    {
        require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");
        bytes32 _name = NameFilter.nameFilter(_nameString);
        address _addr = msg.sender;
        bool _isNewPlayer = determinePID(_addr);
        uint256 _pID = pIDxAddr_[_addr];
        if (_affCode != 0 && _affCode != plyr_[_pID].laff && _affCode != _pID)
        {
            plyr_[_pID].laff = _affCode;
        } else if (_affCode == _pID) {
            _affCode = 0;
        }
        registerNameCore(_pID, _addr, _affCode, _name, _isNewPlayer, _all);
    }
    function registerNameXaddr(string _nameString, address _affCode, bool _all)
    isHuman()
    public
    payable
    {
        require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");
        bytes32 _name = NameFilter.nameFilter(_nameString);
        address _addr = msg.sender;
        bool _isNewPlayer = determinePID(_addr);
        uint256 _pID = pIDxAddr_[_addr];
        uint256 _affID;
        if (_affCode != address(0) && _affCode != _addr)
        {
            _affID = pIDxAddr_[_affCode];
            if (_affID != plyr_[_pID].laff)
            {
                plyr_[_pID].laff = _affID;
            }
        }
        registerNameCore(_pID, _addr, _affID, _name, _isNewPlayer, _all);
    }
    function registerNameXname(string _nameString, bytes32 _affCode, bool _all)
    isHuman()
    public
    payable
    {
        require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");
        bytes32 _name = NameFilter.nameFilter(_nameString);
        address _addr = msg.sender;
        bool _isNewPlayer = determinePID(_addr);
        uint256 _pID = pIDxAddr_[_addr];
        uint256 _affID;
        if (_affCode != "" && _affCode != _name)
        {
            _affID = pIDxName_[_affCode];
            if (_affID != plyr_[_pID].laff)
            {
                plyr_[_pID].laff = _affID;
            }
        }
        registerNameCore(_pID, _addr, _affID, _name, _isNewPlayer, _all);
    }
    function addMeToGame(uint256 _gameID)
    isHuman()
    public
    {
        require(_gameID <= gID_, "silly player, that game doesn't exist yet");
        address _addr = msg.sender;
        uint256 _pID = pIDxAddr_[_addr];
        require(_pID != 0, "hey there buddy, you dont even have an account");
        uint256 _totalNames = plyr_[_pID].names;
        games_[_gameID].receivePlayerInfo(_pID, _addr, plyr_[_pID].name, plyr_[_pID].laff);
        if (_totalNames > 1)
            for (uint256 ii = 1; ii <= _totalNames; ii++)
        games_[_gameID].receivePlayerNameList(_pID, plyrNameList_[_pID][ii]);
    }
    function addMeToAllGames()
    isHuman()
    public
    {
        address _addr = msg.sender;
        uint256 _pID = pIDxAddr_[_addr];
        require(_pID != 0, "hey there buddy, you dont even have an account");
        uint256 _laff = plyr_[_pID].laff;
        uint256 _totalNames = plyr_[_pID].names;
        bytes32 _name = plyr_[_pID].name;
        for (uint256 i = 1; i <= gID_; i++)
        {
            games_[i].receivePlayerInfo(_pID, _addr, _name, _laff);
            if (_totalNames > 1)
                for (uint256 ii = 1; ii <= _totalNames; ii++)
            games_[i].receivePlayerNameList(_pID, plyrNameList_[_pID][ii]);
        }
    }
    function useMyOldName(string _nameString)
    isHuman()
    public
    {
        bytes32 _name = _nameString.nameFilter();
        uint256 _pID = pIDxAddr_[msg.sender];
        require(plyrNames_[_pID][_name] == true, "umm... thats not a name you own");
        plyr_[_pID].name = _name;
    }
    function registerNameCore(uint256 _pID, address _addr, uint256 _affID, bytes32 _name, bool _isNewPlayer, bool _all)
    private
    {
        if (pIDxName_[_name] != 0)
            require(plyrNames_[_pID][_name] == true, "sorry that names already taken");
        plyr_[_pID].name = _name;
        pIDxName_[_name] = _pID;
        if (plyrNames_[_pID][_name] == false)
        {
            plyrNames_[_pID][_name] = true;
            plyr_[_pID].names++;
            plyrNameList_[_pID][plyr_[_pID].names] = _name;
        }
        communityAddr.transfer(address(this).balance);
        if (_all == true)
            for (uint256 i = 1; i <= gID_; i++)
        games_[i].receivePlayerInfo(_pID, _addr, _name, _affID);
        emit onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, msg.value, now);
    }
    function determinePID(address _addr)
    private
    returns (bool)
    {
        if (pIDxAddr_[_addr] == 0)
        {
            pID_++;
            pIDxAddr_[_addr] = pID_;
            plyr_[pID_].addr = _addr;
            return (true);
        } else {
            return (false);
        }
    }
    function getPlayerID(address _addr)
    isRegisteredGame()
    external
    returns (uint256)
    {
        determinePID(_addr);
        return (pIDxAddr_[_addr]);
    }
    function getPlayerName(uint256 _pID)
    external
    view
    returns (bytes32)
    {
        return (plyr_[_pID].name);
    }
    function getPlayerLAff(uint256 _pID)
    external
    view
    returns (uint256)
    {
        return (plyr_[_pID].laff);
    }
    function getPlayerAddr(uint256 _pID)
    external
    view
    returns (address)
    {
        return (plyr_[_pID].addr);
    }
    function getNameFee()
    external
    view
    returns (uint256)
    {
        return(registrationFee_);
    }
    function registerNameXIDFromDapp(address _addr, bytes32 _name, uint256 _affCode, bool _all)
    isRegisteredGame()
    external
    payable
    returns(bool, uint256)
    {
        require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");
        bool _isNewPlayer = determinePID(_addr);
        uint256 _pID = pIDxAddr_[_addr];
        uint256 _affID = _affCode;
        if (_affID != 0 && _affID != plyr_[_pID].laff && _affID != _pID)
        {
            plyr_[_pID].laff = _affID;
        } else if (_affID == _pID) {
            _affID = 0;
        }
        registerNameCore(_pID, _addr, _affID, _name, _isNewPlayer, _all);
        return(_isNewPlayer, _affID);
    }
    function registerNameXaddrFromDapp(address _addr, bytes32 _name, address _affCode, bool _all)
    isRegisteredGame()
    external
    payable
    returns(bool, uint256)
    {
        require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");
        bool _isNewPlayer = determinePID(_addr);
        uint256 _pID = pIDxAddr_[_addr];
        uint256 _affID;
        if (_affCode != address(0) && _affCode != _addr)
        {
            _affID = pIDxAddr_[_affCode];
            if (_affID != plyr_[_pID].laff)
            {
                plyr_[_pID].laff = _affID;
            }
        }
        registerNameCore(_pID, _addr, _affID, _name, _isNewPlayer, _all);
        return(_isNewPlayer, _affID);
    }
    function registerNameXnameFromDapp(address _addr, bytes32 _name, bytes32 _affCode, bool _all)
    isRegisteredGame()
    external
    payable
    returns(bool, uint256)
    {
        require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");
        bool _isNewPlayer = determinePID(_addr);
        uint256 _pID = pIDxAddr_[_addr];
        uint256 _affID;
        if (_affCode != "" && _affCode != _name)
        {
            _affID = pIDxName_[_affCode];
            if (_affID != plyr_[_pID].laff)
            {
                plyr_[_pID].laff = _affID;
            }
        }
        registerNameCore(_pID, _addr, _affID, _name, _isNewPlayer, _all);
        return(_isNewPlayer, _affID);
    }
    function addGame(address _gameAddress, string _gameNameStr)
    onlyCommunity()
    public
    {
        require(gameIDs_[_gameAddress] == 0, "derp, that games already been registered");
        gID_++;
        bytes32 _name = _gameNameStr.nameFilter();
        gameIDs_[_gameAddress] = gID_;
        gameNames_[_gameAddress] = _name;
        games_[gID_] = PlayerBookReceiverInterface(_gameAddress);
        games_[gID_].receivePlayerInfo(1, plyr_[1].addr, plyr_[1].name, 0);
        games_[gID_].receivePlayerInfo(2, plyr_[2].addr, plyr_[2].name, 0);
        games_[gID_].receivePlayerInfo(3, plyr_[3].addr, plyr_[3].name, 0);
        games_[gID_].receivePlayerInfo(4, plyr_[4].addr, plyr_[4].name, 0);
    }
    function setRegistrationFee(uint256 _fee)
    onlyCommunity()
    public
    {
        registrationFee_ = _fee;
    }
}