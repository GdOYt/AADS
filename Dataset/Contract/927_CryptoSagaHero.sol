contract CryptoSagaHero is ERC721Token, Claimable, Pausable, AccessMint, AccessDeploy, AccessDeposit {
  string public constant name = "CryptoSaga Hero";
  string public constant symbol = "HERO";
  struct HeroClass {
    string className;
    uint8 classRank;
    uint8 classRace;
    uint32 classAge;
    uint8 classType;
    uint32 maxLevel; 
    uint8 aura; 
    uint32[5] baseStats;
    uint32[5] minIVForStats;
    uint32[5] maxIVForStats;
    uint32 currentNumberOfInstancedHeroes;
  }
  struct HeroInstance {
    uint32 heroClassId;
    string heroName;
    uint32 currentLevel;
    uint32 currentExp;
    uint32 lastLocationId;
    uint256 availableAt;
    uint32[5] currentStats;
    uint32[5] ivForStats;
  }
  uint32 public requiredExpIncreaseFactor = 100;
  uint256 public requiredGoldIncreaseFactor = 1000000000000000000;
  mapping(uint32 => HeroClass) public heroClasses;
  uint32 public numberOfHeroClasses;
  mapping(uint256 => HeroInstance) public tokenIdToHeroInstance;
  uint256 public numberOfTokenIds;
  Gold public goldContract;
  mapping(address => uint256) public addressToGoldDeposit;
  uint32 private seed = 0;
  event DefineType(
    address indexed _by,
    uint32 indexed _typeId,
    string _className
  );
  event LevelUp(
    address indexed _by,
    uint256 indexed _tokenId,
    uint32 _newLevel
  );
  event Deploy(
    address indexed _by,
    uint256 indexed _tokenId,
    uint32 _locationId,
    uint256 _duration
  );
  function getClassInfo(uint32 _classId)
    external view
    returns (string className, uint8 classRank, uint8 classRace, uint32 classAge, uint8 classType, uint32 maxLevel, uint8 aura, uint32[5] baseStats, uint32[5] minIVs, uint32[5] maxIVs) 
  {
    var _cl = heroClasses[_classId];
    return (_cl.className, _cl.classRank, _cl.classRace, _cl.classAge, _cl.classType, _cl.maxLevel, _cl.aura, _cl.baseStats, _cl.minIVForStats, _cl.maxIVForStats);
  }
  function getClassName(uint32 _classId)
    external view
    returns (string)
  {
    return heroClasses[_classId].className;
  }
  function getClassRank(uint32 _classId)
    external view
    returns (uint8)
  {
    return heroClasses[_classId].classRank;
  }
  function getClassMintCount(uint32 _classId)
    external view
    returns (uint32)
  {
    return heroClasses[_classId].currentNumberOfInstancedHeroes;
  }
  function getHeroInfo(uint256 _tokenId)
    external view
    returns (uint32 classId, string heroName, uint32 currentLevel, uint32 currentExp, uint32 lastLocationId, uint256 availableAt, uint32[5] currentStats, uint32[5] ivs, uint32 bp)
  {
    HeroInstance memory _h = tokenIdToHeroInstance[_tokenId];
    var _bp = _h.currentStats[0] + _h.currentStats[1] + _h.currentStats[2] + _h.currentStats[3] + _h.currentStats[4];
    return (_h.heroClassId, _h.heroName, _h.currentLevel, _h.currentExp, _h.lastLocationId, _h.availableAt, _h.currentStats, _h.ivForStats, _bp);
  }
  function getHeroClassId(uint256 _tokenId)
    external view
    returns (uint32)
  {
    return tokenIdToHeroInstance[_tokenId].heroClassId;
  }
  function getHeroName(uint256 _tokenId)
    external view
    returns (string)
  {
    return tokenIdToHeroInstance[_tokenId].heroName;
  }
  function getHeroLevel(uint256 _tokenId)
    external view
    returns (uint32)
  {
    return tokenIdToHeroInstance[_tokenId].currentLevel;
  }
  function getHeroLocation(uint256 _tokenId)
    external view
    returns (uint32)
  {
    return tokenIdToHeroInstance[_tokenId].lastLocationId;
  }
  function getHeroAvailableAt(uint256 _tokenId)
    external view
    returns (uint256)
  {
    return tokenIdToHeroInstance[_tokenId].availableAt;
  }
  function getHeroBP(uint256 _tokenId)
    public view
    returns (uint32)
  {
    var _tmp = tokenIdToHeroInstance[_tokenId].currentStats;
    return (_tmp[0] + _tmp[1] + _tmp[2] + _tmp[3] + _tmp[4]);
  }
  function getHeroRequiredGoldForLevelUp(uint256 _tokenId)
    public view
    returns (uint256)
  {
    return (uint256(2) ** (tokenIdToHeroInstance[_tokenId].currentLevel / 10)) * requiredGoldIncreaseFactor;
  }
  function getHeroRequiredExpForLevelUp(uint256 _tokenId)
    public view
    returns (uint32)
  {
    return ((tokenIdToHeroInstance[_tokenId].currentLevel + 2) * requiredExpIncreaseFactor);
  }
  function getGoldDepositOfAddress(address _address)
    external view
    returns (uint256)
  {
    return addressToGoldDeposit[_address];
  }
  function getTokenIdOfAddressAndIndex(address _address, uint256 _index)
    external view
    returns (uint256)
  {
    return tokensOf(_address)[_index];
  }
  function getTotalBPOfAddress(address _address)
    external view
    returns (uint32)
  {
    var _tokens = tokensOf(_address);
    uint32 _totalBP = 0;
    for (uint256 i = 0; i < _tokens.length; i ++) {
      _totalBP += getHeroBP(_tokens[i]);
    }
    return _totalBP;
  }
  function setHeroName(uint256 _tokenId, string _name)
    onlyOwnerOf(_tokenId)
    public
  {
    tokenIdToHeroInstance[_tokenId].heroName = _name;
  }
  function setGoldContract(address _contractAddress)
    onlyOwner
    public
  {
    goldContract = Gold(_contractAddress);
  }
  function setRequiredExpIncreaseFactor(uint32 _value)
    onlyOwner
    public
  {
    requiredExpIncreaseFactor = _value;
  }
  function setRequiredGoldIncreaseFactor(uint256 _value)
    onlyOwner
    public
  {
    requiredGoldIncreaseFactor = _value;
  }
  function CryptoSagaHero(address _goldAddress)
    public
  {
    require(_goldAddress != address(0));
    setGoldContract(_goldAddress);
    defineType("Archangel", 4, 1, 13540, 0, 99, 3, [uint32(74), 75, 57, 99, 95], [uint32(8), 6, 8, 5, 5], [uint32(8), 10, 10, 6, 6]);
    defineType("Shadowalker", 3, 4, 134, 1, 75, 4, [uint32(45), 35, 60, 80, 40], [uint32(3), 2, 10, 4, 5], [uint32(5), 5, 10, 7, 5]);
    defineType("Pyromancer", 2, 0, 14, 2, 50, 1, [uint32(50), 28, 17, 40, 35], [uint32(5), 3, 2, 3, 3], [uint32(8), 4, 3, 4, 5]);
    defineType("Magician", 1, 3, 224, 2, 30, 0, [uint32(35), 15, 25, 25, 30], [uint32(3), 1, 2, 2, 2], [uint32(5), 2, 3, 3, 3]);
    defineType("Farmer", 0, 0, 59, 0, 15, 2, [uint32(10), 22, 8, 15, 25], [uint32(1), 2, 1, 1, 2], [uint32(1), 3, 1, 2, 3]);
  }
  function defineType(string _className, uint8 _classRank, uint8 _classRace, uint32 _classAge, uint8 _classType, uint32 _maxLevel, uint8 _aura, uint32[5] _baseStats, uint32[5] _minIVForStats, uint32[5] _maxIVForStats)
    onlyOwner
    public
  {
    require(_classRank < 5);
    require(_classType < 3);
    require(_aura < 5);
    require(_minIVForStats[0] <= _maxIVForStats[0] && _minIVForStats[1] <= _maxIVForStats[1] && _minIVForStats[2] <= _maxIVForStats[2] && _minIVForStats[3] <= _maxIVForStats[3] && _minIVForStats[4] <= _maxIVForStats[4]);
    HeroClass memory _heroType = HeroClass({
      className: _className,
      classRank: _classRank,
      classRace: _classRace,
      classAge: _classAge,
      classType: _classType,
      maxLevel: _maxLevel,
      aura: _aura,
      baseStats: _baseStats,
      minIVForStats: _minIVForStats,
      maxIVForStats: _maxIVForStats,
      currentNumberOfInstancedHeroes: 0
    });
    heroClasses[numberOfHeroClasses] = _heroType;
    DefineType(msg.sender, numberOfHeroClasses, _heroType.className);
    numberOfHeroClasses ++;
  }
  function mint(address _owner, uint32 _heroClassId)
    onlyAccessMint
    public
    returns (uint256)
  {
    require(_owner != address(0));
    require(_heroClassId < numberOfHeroClasses);
    var _heroClassInfo = heroClasses[_heroClassId];
    _mint(_owner, numberOfTokenIds);
    uint32[5] memory _ivForStats;
    uint32[5] memory _initialStats;
    for (uint8 i = 0; i < 5; i++) {
      _ivForStats[i] = (random(_heroClassInfo.maxIVForStats[i] + 1, _heroClassInfo.minIVForStats[i]));
      _initialStats[i] = _heroClassInfo.baseStats[i] + _ivForStats[i];
    }
    HeroInstance memory _heroInstance = HeroInstance({
      heroClassId: _heroClassId,
      heroName: "",
      currentLevel: 1,
      currentExp: 0,
      lastLocationId: 0,
      availableAt: now,
      currentStats: _initialStats,
      ivForStats: _ivForStats
    });
    tokenIdToHeroInstance[numberOfTokenIds] = _heroInstance;
    numberOfTokenIds ++;
    _heroClassInfo.currentNumberOfInstancedHeroes ++;
    return numberOfTokenIds - 1;
  }
  function deploy(uint256 _tokenId, uint32 _locationId, uint256 _duration)
    onlyAccessDeploy
    public
    returns (bool)
  {
    require(ownerOf(_tokenId) != address(0));
    var _heroInstance = tokenIdToHeroInstance[_tokenId];
    require(_heroInstance.availableAt <= now);
    _heroInstance.lastLocationId = _locationId;
    _heroInstance.availableAt = now + _duration;
    Deploy(msg.sender, _tokenId, _locationId, _duration);
  }
  function addExp(uint256 _tokenId, uint32 _exp)
    onlyAccessDeploy
    public
    returns (bool)
  {
    require(ownerOf(_tokenId) != address(0));
    var _heroInstance = tokenIdToHeroInstance[_tokenId];
    var _newExp = _heroInstance.currentExp + _exp;
    require(_newExp == uint256(uint128(_newExp)));
    _heroInstance.currentExp += _newExp;
  }
  function addDeposit(address _to, uint256 _amount)
    onlyAccessDeposit
    public
  {
    addressToGoldDeposit[_to] += _amount;
  }
  function levelUp(uint256 _tokenId)
    onlyOwnerOf(_tokenId) whenNotPaused
    public
  {
    var _heroInstance = tokenIdToHeroInstance[_tokenId];
    require(_heroInstance.availableAt <= now);
    var _heroClassInfo = heroClasses[_heroInstance.heroClassId];
    require(_heroInstance.currentLevel < _heroClassInfo.maxLevel);
    var requiredExp = getHeroRequiredExpForLevelUp(_tokenId);
    require(_heroInstance.currentExp >= requiredExp);
    var requiredGold = getHeroRequiredGoldForLevelUp(_tokenId);
    var _ownerOfToken = ownerOf(_tokenId);
    require(addressToGoldDeposit[_ownerOfToken] >= requiredGold);
    _heroInstance.currentLevel += 1;
    for (uint8 i = 0; i < 5; i++) {
      _heroInstance.currentStats[i] = _heroClassInfo.baseStats[i] + (_heroInstance.currentLevel - 1) * _heroInstance.ivForStats[i];
    }
    _heroInstance.currentExp -= requiredExp;
    addressToGoldDeposit[_ownerOfToken] -= requiredGold;
    LevelUp(msg.sender, _tokenId, _heroInstance.currentLevel);
  }
  function transferDeposit(uint256 _amount)
    whenNotPaused
    public
  {
    require(goldContract.allowance(msg.sender, this) >= _amount);
    if (goldContract.transferFrom(msg.sender, this, _amount)) {
      addressToGoldDeposit[msg.sender] += _amount;
    }
  }
  function withdrawDeposit(uint256 _amount)
    public
  {
    require(addressToGoldDeposit[msg.sender] >= _amount);
    if (goldContract.transfer(msg.sender, _amount)) {
      addressToGoldDeposit[msg.sender] -= _amount;
    }
  }
  function random(uint32 _upper, uint32 _lower)
    private
    returns (uint32)
  {
    require(_upper > _lower);
    seed = uint32(keccak256(keccak256(block.blockhash(block.number), seed), now));
    return seed % (_upper - _lower) + _lower;
  }
}
