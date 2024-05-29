contract RBACMixin {
  string constant FORBIDDEN = "Haven't enough right to access";
  mapping (address => bool) public owners;
  mapping (address => bool) public minters;
  event AddOwner(address indexed who);
  event DeleteOwner(address indexed who);
  event AddMinter(address indexed who);
  event DeleteMinter(address indexed who);
  constructor () public {
    _setOwner(msg.sender, true);
  }
  modifier onlyOwner() {
    require(isOwner(msg.sender), FORBIDDEN);
    _;
  }
  modifier onlyMinter() {
    require(isMinter(msg.sender), FORBIDDEN);
    _;
  }
  function isOwner(address _who) public view returns (bool) {
    return owners[_who];
  }
  function isMinter(address _who) public view returns (bool) {
    return minters[_who];
  }
  function addOwner(address _who) public onlyOwner returns (bool) {
    _setOwner(_who, true);
  }
  function deleteOwner(address _who) public onlyOwner returns (bool) {
    _setOwner(_who, false);
  }
  function addMinter(address _who) public onlyOwner returns (bool) {
    _setMinter(_who, true);
  }
  function deleteMinter(address _who) public onlyOwner returns (bool) {
    _setMinter(_who, false);
  }
  function _setOwner(address _who, bool _flag) private returns (bool) {
    require(owners[_who] != _flag);
    owners[_who] = _flag;
    if (_flag) {
      emit AddOwner(_who);
    } else {
      emit DeleteOwner(_who);
    }
    return true;
  }
  function _setMinter(address _who, bool _flag) private returns (bool) {
    require(minters[_who] != _flag);
    minters[_who] = _flag;
    if (_flag) {
      emit AddMinter(_who);
    } else {
      emit DeleteMinter(_who);
    }
    return true;
  }
}
