contract CryptoSagaSwapPLAT is Pausable{
  address public wallet;
  CryptoSagaHero public heroContract;
  uint256 public ethPrice = 20000000000000000;  
  PLATPriceOracle public platPriceOracleContract;
  BitGuildToken public platContract;
  mapping(uint32 => bool) public blackList;
  uint32 private seed = 0;
  function setEthPrice(uint256 _value)
    onlyOwner
    public
  {
    ethPrice = _value;
  }
  function setBlacklist(uint32 _classId, bool _value)
    onlyOwner
    public
  {
    blackList[_classId] = _value;
  }
  function CryptoSagaSwapPLAT(address _heroAddress, address _platAddress, address _platPriceOracleAddress, address _walletAddress)
    public
  {
    require(_heroAddress != address(0));
    require(_platAddress != address(0));
    require(_platPriceOracleAddress != address(0));
    require(_walletAddress != address(0));
    wallet = _walletAddress;
    heroContract = CryptoSagaHero(_heroAddress);
    platContract = BitGuildToken(_platAddress);
    platPriceOracleContract = PLATPriceOracle(_platPriceOracleAddress);
  }
  function receiveApproval(address _sender, uint256 _value, BitGuildToken _tokenContract, bytes _extraData)
    public
    whenNotPaused
  {
    require(msg.sender != address(0));
    require(_tokenContract == platContract);
    require(_tokenContract.transferFrom(_sender, address(this), _value));
    require(_extraData.length != 0);
    uint256 _amount;
    for(uint256 i = 0; i < _extraData.length; i++) {
      _amount = _amount + uint(_extraData[i]) * (2 ** (8 * (_extraData.length - (i + 1))));
    }
    require(_amount >= 1 && _amount <= 5);
    uint256 _priceOfBundle = _amount * ethPrice * platPriceOracleContract.ETHPrice() / (10 ** 18);
    require(_value >= _priceOfBundle);
    payWithPLAT(_amount);
  }
  function payWithPLAT(uint256 _amount)
    private
  {
    for (uint i = 0; i < _amount; i ++) {
      var _randomValue = random(10000, 0);
      uint8 _heroRankToMint = 0; 
      if (_randomValue < 5000) {
        _heroRankToMint = 1;
      } else if (_randomValue < 9550) {
        _heroRankToMint = 2;
      }  else if (_randomValue < 9950) {
        _heroRankToMint = 3;
      } else {
        _heroRankToMint = 4;
      }
      summonHero(msg.sender, _heroRankToMint);
    }
  }
  function summonHero(address _to, uint8 _heroRankToMint)
    private
    returns (uint256)
  {
    uint32 _numberOfClasses = heroContract.numberOfHeroClasses();
    uint32[] memory _candidates = new uint32[](_numberOfClasses);
    uint32 _count = 0;
    for (uint32 i = 0; i < _numberOfClasses; i ++) {
      if (heroContract.getClassRank(i) == _heroRankToMint && blackList[i] != true) {
        _candidates[_count] = i;
        _count++;
      }
    }
    require(_count != 0);
    return heroContract.mint(_to, _candidates[random(_count, 0)]);
  }
  function random(uint32 _upper, uint32 _lower)
    private
    returns (uint32)
  {
    require(_upper > _lower);
    seed = uint32(keccak256(keccak256(block.blockhash(block.number - 1), seed), now));
    return seed % (_upper - _lower) + _lower;
  }
}
