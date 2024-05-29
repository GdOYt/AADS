contract BattleBase is Ownable {
	 using SafeMath for uint256;
	event BattleHistory(
		uint256 historyId,
		uint8 winner,  
		uint64 battleTime,
		uint256 sequence,
		uint256 blockNumber,
		uint256 tokensGained);
	event BattleHistoryChallenger(
		uint256 historyId,
		uint256 cardId,
		uint8 element,
		uint16 level,
		uint32 attack,
		uint32 defense,
		uint32 hp,
		uint32 speed,
		uint32 criticalRate,
		uint256 rank);
	event BattleHistoryDefender(
		uint256 historyId,
		uint256 cardId,
		uint8 element,
		uint16 level,
		uint32 attack,
		uint32 defense,
		uint32 hp,
		uint32 speed,
		uint16 criticalRate,
		uint256 rank);
	event RejectChallenge(
		uint256 challengerId,
		uint256 defenderId,
		uint256 defenderRank,
		uint8 rejectCode,
		uint256 blockNumber);
	event HashUpdated(
		uint256 cardId, 
		uint256 cardHash);
	event LevelUp(uint256 cardId);
	event CardCreated(address owner, uint256 cardId);
	uint32[] expToNextLevelArr = [0,103,103,207,207,207,414,414,414,414,724,724,724,828,828,931,931,1035,1035,1138,1138,1242,1242,1345,1345,1449,1449,1552,1552,1656,1656,1759,1759,1863,1863,1966,1966,2070,2070,2173,2173,2173,2277,2277,2380,2380,2484,2484,2587,2587,2691,2691,2794,2794,2898,2898,3001,3001,3105,3105,3208,3208,3312,3312,3415,3415,3519,3519,3622,3622,3622,3726,3726,3829,3829,3933,3933,4036,4036,4140,4140,4243,4243,4347,4347,4450,4450,4554,4554,4657,4657,4761,4761,4864,4864,4968,4968,5071,5071,5175];
	uint32[] activeWinExp = [10,11,14,19,26,35,46,59,74,91,100,103,108,116,125,135,146,158,171,185,200,215,231,248,265,283,302,321,341,361,382];
	struct Card {
		uint8 element;  
		uint16 level;  
		uint32 attack;
		uint32 defense;
		uint32 hp;
		uint32 speed;
		uint16 criticalRate;  
		uint32 flexiGems;
		uint256 cardHash;
		uint32 currentExp;
		uint32 expToNextLevel;
		uint64 createdDatetime;
		uint256 rank;  
	}
	mapping (uint256 => Card) public cards;
	uint256[] ranking;  
	mapping (uint256 => uint256) public rankTokens;
	uint8 public currentElement = 0;  
	uint256 public historyId = 0;
	HogSmashToken public hogsmashToken;
	Marketplace public marketplace;
	uint256 public challengeFee;
	uint256 public upgradeFee;
	uint256 public avatarFee;
	uint256 public referrerFee;
	uint256 public developerCut;
	uint256 internal totalDeveloperCut;
	uint256 public cardDrawPrice;
	uint8 public upgradeGems;  
	uint8 public upgradeGemsSpecial;
	uint16 public gemAttackConversion;
	uint16 public gemDefenseConversion;
	uint16 public gemHpConversion;
	uint16 public gemSpeedConversion;
	uint16 public gemCriticalRateConversion;
	uint8 public goldPercentage;
	uint8 public silverPercentage;
	uint32 public eventCardRangeMin;
	uint32 public eventCardRangeMax;
	uint8 public maxBattleRounds;  
	uint256 internal totalRankTokens;
	bool internal battleStart;
	bool internal starterPackOnSale;
	uint256 public starterPackPrice;  
	uint16 public starterPackCardLevel;  
	function setMarketplaceAddress(address _address) external onlyOwner {
		Marketplace candidateContract = Marketplace(_address);
		require(candidateContract.isMarketplace(),"needs to be marketplace");
		marketplace = candidateContract;
	}
	function setSettingValues(  uint8 _upgradeGems,
	uint8 _upgradeGemsSpecial,
	uint16 _gemAttackConversion,
	uint16 _gemDefenseConversion,
	uint16 _gemHpConversion,
	uint16 _gemSpeedConversion,
	uint16 _gemCriticalRateConversion,
	uint8 _goldPercentage,
	uint8 _silverPercentage,
	uint32 _eventCardRangeMin,
	uint32 _eventCardRangeMax,
	uint8 _newMaxBattleRounds) external onlyOwner {
		require(_eventCardRangeMax >= _eventCardRangeMin, "range max must be larger or equals range min" );
		require(_eventCardRangeMax<100000000, "range max cannot exceed 99999999");
		require((_newMaxBattleRounds <= 128) && (_newMaxBattleRounds >0), "battle rounds must be between 0 and 128");
		upgradeGems = _upgradeGems;
		upgradeGemsSpecial = _upgradeGemsSpecial;
		gemAttackConversion = _gemAttackConversion;
		gemDefenseConversion = _gemDefenseConversion;
		gemHpConversion = _gemHpConversion;
		gemSpeedConversion = _gemSpeedConversion;
		gemCriticalRateConversion = _gemCriticalRateConversion;
		goldPercentage = _goldPercentage;
		silverPercentage = _silverPercentage;
		eventCardRangeMin = _eventCardRangeMin;
		eventCardRangeMax = _eventCardRangeMax;
		maxBattleRounds = _newMaxBattleRounds;
	}
	function setStarterPack(uint256 _newStarterPackPrice, uint16 _newStarterPackCardLevel) external onlyOwner {
		require(_newStarterPackCardLevel<=20, "starter pack level cannot exceed 20");  
		starterPackPrice = _newStarterPackPrice;
		starterPackCardLevel = _newStarterPackCardLevel;		
	} 	
	function setStarterPackOnSale(bool _newStarterPackOnSale) external onlyOwner {
		starterPackOnSale = _newStarterPackOnSale;
	}
	function setBattleStart(bool _newBattleStart) external onlyOwner {
		battleStart = _newBattleStart;
	}
	function setCardDrawPrice(uint256 _newCardDrawPrice) external onlyOwner {
		cardDrawPrice = _newCardDrawPrice;
	}
	function setReferrerFee(uint256 _newReferrerFee) external onlyOwner {
		referrerFee = _newReferrerFee;
	}
	function setChallengeFee(uint256 _newChallengeFee) external onlyOwner {
		challengeFee = _newChallengeFee;
	}
	function setUpgradeFee(uint256 _newUpgradeFee) external onlyOwner {
		upgradeFee = _newUpgradeFee;
	}
	function setAvatarFee(uint256 _newAvatarFee) external onlyOwner {
		avatarFee = _newAvatarFee;
	}
	function setDeveloperCut(uint256 _newDeveloperCut) external onlyOwner {
		developerCut = _newDeveloperCut;
	}
	function getTotalDeveloperCut() external view onlyOwner returns (uint256) {
		return totalDeveloperCut;
	}
	function getTotalRankTokens() external view returns (uint256) {
		return totalRankTokens;
	}
	function getSettingValues() external view returns(  uint8 _upgradeGems,
															uint8 _upgradeGemsSpecial,
															uint16 _gemAttackConversion,
															uint16 _gemDefenseConversion,
															uint16 _gemHpConversion,
															uint16 _gemSpeedConversion,
															uint16 _gemCriticalRateConversion,
															uint8 _maxBattleRounds)
	{
		_upgradeGems = uint8(upgradeGems);
		_upgradeGemsSpecial = uint8(upgradeGemsSpecial);
		_gemAttackConversion = uint16(gemAttackConversion);
		_gemDefenseConversion = uint16(gemDefenseConversion);
		_gemHpConversion = uint16(gemHpConversion);
		_gemSpeedConversion = uint16(gemSpeedConversion);
		_gemCriticalRateConversion = uint16(gemCriticalRateConversion);
		_maxBattleRounds = uint8(maxBattleRounds);
	}
}
