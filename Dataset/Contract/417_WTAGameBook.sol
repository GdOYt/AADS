contract WTAGameBook is Ownable{
  using SafeMath for uint256;
  string public name = "WTAGameBook V0.5";
  string public version = "0.5";
  address[] public admins;
  mapping (address => uint256) public adminId;
  address[] public games;
  mapping (address => uint256) public gameId;
  struct PlayerInfo {
    uint256 pid;
    address paddr;
    uint256 referrer;
  }
  uint256 public playerNum = 0;
  mapping (uint256 => PlayerInfo) public player;
  mapping (address => uint256) public playerId;
  event AdminAdded(address indexed _addr, uint256 _id, address indexed _adder);
  event AdminRemoved(address indexed _addr, uint256 _id, address indexed _remover);
  event GameAdded(address indexed _addr, uint256 _id, address indexed _adder);
  event GameRemoved(address indexed _addr, uint256 _id, address indexed _remover);
  event PlayerAdded(uint256 _pid, address indexed _paddr, uint256 _ref, address indexed _adder);
  event WrongTokenEmptied(address indexed _token, address indexed _addr, uint256 _amount);
  event WrongEtherEmptied(address indexed _addr, uint256 _amount);
  function isHuman(address _addr) public view returns (bool) {
    uint256 _codeLength;
    assembly {_codeLength := extcodesize(_addr)}
    return (_codeLength == 0);
  }
  modifier validAddress(address _addr) {
		require(_addr != 0x0, "validAddress wrong");
		_;
	}
  modifier onlyAdmin() {
    require(adminId[msg.sender] != 0, "onlyAdmin wrong");
    _;
  }
  modifier onlyAdminOrGame() {
    require((adminId[msg.sender] != 0) || (gameId[msg.sender] != 0), "onlyAdminOrGame wrong");
    _;
  }
  constructor() public {
    adminId[address(0x0)] = 0;
    admins.length++;
    admins[0] = address(0x0);
    gameId[address(0x0)] = 0;
    games.length++;
    games[0] = address(0x0);
    addAdmin(owner);
  }
  function addAdmin(address _admin) onlyOwner validAddress(_admin) public {
    require(isHuman(_admin), "addAdmin human only");
    uint256 id = adminId[_admin];
    if (id == 0) {
      adminId[_admin] = admins.length;
      id = admins.length++;
    }
    admins[id] = _admin;
    emit AdminAdded(_admin, id, msg.sender);
  }
  function removeAdmin(address _admin) onlyOwner validAddress(_admin) public {
    require(adminId[_admin] != 0, "removeAdmin wrong");
    uint256 aid = adminId[_admin];
    adminId[_admin] = 0;
    for (uint256 i = aid; i<admins.length-1; i++){
        admins[i] = admins[i+1];
        adminId[admins[i]] = i;
    }
    delete admins[admins.length-1];
    admins.length--;
    emit AdminRemoved(_admin, aid, msg.sender);
  }
  function addGame(address _game) onlyAdmin validAddress(_game) public {
    require(!isHuman(_game), "addGame inhuman only");
    uint256 id = gameId[_game];
    if (id == 0) {
      gameId[_game] = games.length;
      id = games.length++;
    }
    games[id] = _game;
    emit GameAdded(_game, id, msg.sender);
  }
  function removeGame(address _game) onlyAdmin validAddress(_game) public {
    require(gameId[_game] != 0, "removeGame wrong");
    uint256 gid = gameId[_game];
    gameId[_game] = 0;
    for (uint256 i = gid; i<games.length-1; i++){
        games[i] = games[i+1];
        gameId[games[i]] = i;
    }
    delete games[games.length-1];
    games.length--;
    emit GameRemoved(_game, gid, msg.sender);
  }
  function addPlayer(address _addr, uint256 _ref) onlyAdminOrGame validAddress(_addr) public returns (uint256) {
    require(isHuman(_addr), "addPlayer human only");
    require((_ref < playerNum.add(1)) && (playerId[_addr] == 0), "addPlayer parameter wrong");
    playerId[_addr] = playerNum.add(1);
    player[playerNum.add(1)] = PlayerInfo({pid: playerNum.add(1), paddr: _addr, referrer: _ref});
    playerNum++;
    emit PlayerAdded(playerNum, _addr, _ref, msg.sender);
    return playerNum;
  }
  function getPlayerIdByAddress(address _addr) validAddress(_addr) public view returns (uint256) {
    return playerId[_addr];
  }
  function getPlayerAddressById(uint256 _id) public view returns (address) {
    require(_id <= playerNum && _id > 0, "getPlayerAddressById wrong");
    return player[_id].paddr;
  }
  function getPlayerRefById(uint256 _id) public view returns (uint256) {
    require(_id <= playerNum && _id > 0, "getPlayerRefById wrong");
    return player[_id].referrer;
  }
  function getGameIdByAddress(address _addr) validAddress(_addr) public view returns (uint256) {
    return gameId[_addr];
  }
  function getGameAddressById(uint256 _id) public view returns (address) {
    require(_id < games.length && _id > 0, "getGameAddressById wrong");
    return games[_id];
  }
  function isAdmin(address _addr) validAddress(_addr) public view returns (bool) {
    return (adminId[_addr] > 0);
  }
  function () public payable {
    revert();
  }
  function emptyWrongToken(address _addr) onlyAdmin public {
    ERC20Token wrongToken = ERC20Token(_addr);
    uint256 amount = wrongToken.balanceOf(address(this));
    require(amount > 0, "emptyToken need more balance");
    require(wrongToken.transfer(msg.sender, amount), "empty Token transfer wrong");
    emit WrongTokenEmptied(_addr, msg.sender, amount);
  }
  function emptyWrongEther() onlyAdmin public {
    uint256 amount = address(this).balance;
    require(amount > 0, "emptyEther need more balance");
    msg.sender.transfer(amount);
    emit WrongEtherEmptied(msg.sender, amount);
  }
}
