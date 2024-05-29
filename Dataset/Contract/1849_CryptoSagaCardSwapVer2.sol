contract CryptoSagaCardSwapVer2 is CryptoSagaCardSwap, Pausable{
  address public wallet;
  CryptoSagaHero public heroContract;
  Gold public goldContract;
  uint256 public ethPrice = 20000000000000000;  
  uint256 public goldPrice = 100000000000000000000;  
  uint256 public mileagePointPrice = 100;
  mapping(uint32 => bool) public blackList;
  mapping(address => uint256) public addressToMileagePoint;
  mapping(address => uint256) public addressToFreeSummonTimestamp;
  uint32 private seed = 0;
  function getMileagePoint(address _address)
    public view
    returns (uint256)
  {
    return addressToMileagePoint[_address];
  }
  function getFreeSummonTimestamp(address _address)
    public view
    returns (uint256)
  {
    return addressToFreeSummonTimestamp[_address];
  }
  function setEthPrice(uint256 _value)
    onlyOwner
    public
  {
    ethPrice = _value;
  }
  function setGoldPrice(uint256 _value)
    onlyOwner
    public
  {
    goldPrice = _value;
  }
  function setMileagePointPrice(uint256 _value)
    onlyOwner
    public
  {
    mileagePointPrice = _value;
  }
  function setBlacklist(uint32 _classId, bool _value)
    onlyOwner
    public
  {
    blackList[_classId] = _value;
  }
  function addMileagePoint(address _beneficiary, uint256 _point)
    onlyOwner
    public
  {
    require(_beneficiary != address(0));
    addressToMileagePoint[_beneficiary] += _point;
  }
  function CryptoSagaCardSwapVer2(address _heroAddress, address _goldAddress, address _cardAddress, address _walletAddress)
    public
  {
    require(_heroAddress != address(0));
    require(_goldAddress != address(0));
    require(_cardAddress != address(0));
    require(_walletAddress != address(0));
    wallet = _walletAddress;
    heroContract = CryptoSagaHero(_heroAddress);
    goldContract = Gold(_goldAddress);
    setCardContract(_cardAddress);
  }
  function swapCardForReward(address _by, uint8 _rank)
    onlyCard
    whenNotPaused
    public
    returns (uint256)
  {
    require(tx.origin != _by && tx.origin != msg.sender);
    var _randomValue = random(10000, 0);
    uint8 _heroRankToMint = 0; 
    if (_rank == 0) {  
      if (_randomValue < 8500) {
        _heroRankToMint = 3;
      } else {
        _heroRankToMint = 4;
      }
    } else if (_rank == 3) {  
      if (_randomValue < 6500) {
        _heroRankToMint = 1;
      } else if (_randomValue < 9945) {
        _heroRankToMint = 2;
      }  else if (_randomValue < 9995) {
        _heroRankToMint = 3;
      } else {
        _heroRankToMint = 4;
      }
    } else {  
      _heroRankToMint = 0;
    }
    return summonHero(tx.origin, _heroRankToMint);
  }
  function payWithEth(uint256 _amount, address _referralAddress)
    whenNotPaused
    public
    payable
  {
    require(msg.sender != address(0));
    require(msg.sender != _referralAddress);
    require(_amount >= 1 && _amount <= 5);
    var _priceOfBundle = ethPrice * _amount;
    require(msg.value >= _priceOfBundle);
    wallet.transfer(_priceOfBundle);
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
      if (_referralAddress != address(0)) {
        addressToMileagePoint[_referralAddress] += 5;
        addressToMileagePoint[msg.sender] += 3;
      }
    }
  }
  function payWithGold(uint256 _amount)
    whenNotPaused
    public
  {
    require(msg.sender != address(0));
    require(_amount >= 1 && _amount <= 5);
    var _priceOfBundle = goldPrice * _amount;
    require(goldContract.allowance(msg.sender, this) >= _priceOfBundle);
    if (goldContract.transferFrom(msg.sender, this, _priceOfBundle)) {
      for (uint i = 0; i < _amount; i ++) {
        var _randomValue = random(10000, 0);
        uint8 _heroRankToMint = 0; 
        if (_randomValue < 3000) {
          _heroRankToMint = 0;
        } else if (_randomValue < 7500) {
          _heroRankToMint = 1;
        } else if (_randomValue < 9945) {
          _heroRankToMint = 2;
        } else if (_randomValue < 9995) {
          _heroRankToMint = 3;
        } else {
          _heroRankToMint = 4;
        }
        summonHero(msg.sender, _heroRankToMint);
      }
    }
  }
  function payWithMileagePoint(uint256 _amount)
    whenNotPaused
    public
  {
    require(msg.sender != address(0));
    require(_amount >= 1 && _amount <= 5);
    var _priceOfBundle = mileagePointPrice * _amount;
    require(addressToMileagePoint[msg.sender] >= _priceOfBundle);
    addressToMileagePoint[msg.sender] -= _priceOfBundle;
    for (uint i = 0; i < _amount; i ++) {
      var _randomValue = random(10000, 0);
      uint8 _heroRankToMint = 0; 
      if (_randomValue < 5000) {
        _heroRankToMint = 1;
      } else if (_randomValue < 9050) {
        _heroRankToMint = 2;
      }  else if (_randomValue < 9950) {
        _heroRankToMint = 3;
      } else {
        _heroRankToMint = 4;
      }
      summonHero(msg.sender, _heroRankToMint);
    }
  }
  function payWithDailyFreePoint()
    whenNotPaused
    public
  {
    require(msg.sender != address(0));
    require(now > addressToFreeSummonTimestamp[msg.sender] + 1 days);
    addressToFreeSummonTimestamp[msg.sender] = now;
    var _randomValue = random(10000, 0);
    uint8 _heroRankToMint = 0; 
    if (_randomValue < 5500) {
      _heroRankToMint = 0;
    } else if (_randomValue < 9850) {
      _heroRankToMint = 1;
    } else {
      _heroRankToMint = 2;
    }
    summonHero(msg.sender, _heroRankToMint);
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
