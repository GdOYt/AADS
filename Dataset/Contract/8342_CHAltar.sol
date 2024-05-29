contract CHAltar is CHArena {
  event NewAltarRecord(uint256 id, uint256 ethereum);
  event ChickenToAltar(address indexed user, uint256 id, uint256 chicken);
  event EthereumFromAltar(address indexed user, uint256 id, uint256 ethereum);
  struct AltarRecord {
    uint256 ethereum;
    uint256 chicken;
  }
  struct TradeBook {
    uint256 altarRecordId;
    uint256 chicken;
  }
  uint256 public genesis;
  mapping (uint256 => AltarRecord) public altarRecords;
  mapping (address => TradeBook) public tradeBooks;
  function chickenToAltar(uint256 _chicken) external {
    require(_chicken > 0);
    _payChicken(msg.sender, _chicken);
    uint256 _id = _getCurrentAltarRecordId();
    AltarRecord storage _altarRecord = _getAltarRecord(_id);
    require(_altarRecord.ethereum * _chicken / _chicken == _altarRecord.ethereum);
    TradeBook storage _tradeBook = tradeBooks[msg.sender];
    if (_tradeBook.altarRecordId < _id) {
      _resolveTradeBook(_tradeBook);
      _tradeBook.altarRecordId = _id;
    }
    _altarRecord.chicken = _altarRecord.chicken.add(_chicken);
    _tradeBook.chicken += _chicken;
    emit ChickenToAltar(msg.sender, _id, _chicken);
  }
  function ethereumFromAltar() external {
    uint256 _id = _getCurrentAltarRecordId();
    TradeBook storage _tradeBook = tradeBooks[msg.sender];
    require(_tradeBook.altarRecordId < _id);
    _resolveTradeBook(_tradeBook);
  }
  function tradeBookOf(address _user)
    public
    view
    returns (
      uint256 _id,
      uint256 _ethereum,
      uint256 _totalChicken,
      uint256 _chicken,
      uint256 _income
    )
  {
    TradeBook memory _tradeBook = tradeBooks[_user];
    _id = _tradeBook.altarRecordId;
    _chicken = _tradeBook.chicken;
    AltarRecord memory _altarRecord = altarRecords[_id];
    _totalChicken = _altarRecord.chicken;
    _ethereum = _altarRecord.ethereum;
    _income = _totalChicken > 0 ? _ethereum.mul(_chicken) / _totalChicken : 0;
  }
  function _resolveTradeBook(TradeBook storage _tradeBook) internal {
    if (_tradeBook.chicken > 0) {
      AltarRecord memory _oldAltarRecord = altarRecords[_tradeBook.altarRecordId];
      uint256 _ethereum = _oldAltarRecord.ethereum.mul(_tradeBook.chicken) / _oldAltarRecord.chicken;
      delete _tradeBook.chicken;
      ethereumBalance[msg.sender] = ethereumBalance[msg.sender].add(_ethereum);
      emit EthereumFromAltar(msg.sender, _tradeBook.altarRecordId, _ethereum);
    }
  }
  function _getCurrentAltarRecordId() internal view returns (uint256) {
    return (block.timestamp - genesis) / 86400;
  }
  function _getAltarRecord(uint256 _id) internal returns (AltarRecord storage _altarRecord) {
    _altarRecord = altarRecords[_id];
    if (_altarRecord.ethereum == 0) {
      uint256 _ethereum = altarFund / 10;
      _altarRecord.ethereum = _ethereum;
      altarFund -= _ethereum;
      emit NewAltarRecord(_id, _ethereum);
    }
  }
}
