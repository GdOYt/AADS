contract CardsBase is JadeCoin {
  function CardsBase() public {
    setAdminContract(msg.sender,true);
    setActionContract(msg.sender,true);
  }
  struct Player {
    address owneraddress;
  }
  Player[] players;
  bool gameStarted;
  GameConfigInterface public schema;
  mapping(address => mapping(uint256 => uint256)) public unitsOwned;   
  mapping(address => mapping(uint256 => uint256)) public upgradesOwned;   
  mapping(address => uint256) public uintsOwnerCount;  
  mapping(address=> mapping(uint256 => uint256)) public uintProduction;   
  mapping(address => mapping(uint256 => uint256)) public unitCoinProductionIncreases;  
  mapping(address => mapping(uint256 => uint256)) public unitCoinProductionMultiplier;  
  mapping(address => mapping(uint256 => uint256)) public unitAttackIncreases;
  mapping(address => mapping(uint256 => uint256)) public unitAttackMultiplier;
  mapping(address => mapping(uint256 => uint256)) public unitDefenseIncreases;
  mapping(address => mapping(uint256 => uint256)) public unitDefenseMultiplier;
  mapping(address => mapping(uint256 => uint256)) public unitJadeStealingIncreases;
  mapping(address => mapping(uint256 => uint256)) public unitJadeStealingMultiplier;
  mapping(address => mapping(uint256 => uint256)) private unitMaxCap;  
  function setConfigAddress(address _address) external onlyOwner {
    schema = GameConfigInterface(_address);
  }
  function beginGame(uint256 firstDivsTime) external payable onlyOwner {
    require(!gameStarted);
    gameStarted = true;
    nextSnapshotTime = firstDivsTime;
    totalEtherPool[1] = msg.value;   
  }
  function endGame() external payable onlyOwner {
    require(gameStarted);
    gameStarted = false;
  }
  function getGameStarted() external constant returns (bool) {
    return gameStarted;
  }
  function AddPlayers(address _address) external onlyAccess { 
    Player memory _player= Player({
      owneraddress: _address
    });
    players.push(_player);
  }
  function getRanking() external view returns (address[], uint256[],uint256[]) {
    uint256 len = players.length;
    uint256[] memory arr = new uint256[](len);
    address[] memory arr_addr = new address[](len);
    uint256[] memory arr_def = new uint256[](len);
    uint counter =0;
    for (uint k=0;k<len; k++){
      arr[counter] =  getJadeProduction(players[k].owneraddress);
      arr_addr[counter] = players[k].owneraddress;
      (,arr_def[counter],,) = getPlayersBattleStats(players[k].owneraddress);
      counter++;
    }
    for(uint i=0;i<len-1;i++) {
      for(uint j=0;j<len-i-1;j++) {
        if(arr[j]<arr[j+1]) {
          uint256 temp = arr[j];
          address temp_addr = arr_addr[j];
          uint256 temp_def = arr_def[j];
          arr[j] = arr[j+1];
          arr[j+1] = temp;
          arr_addr[j] = arr_addr[j+1];
          arr_addr[j+1] = temp_addr;
          arr_def[j] = arr_def[j+1];
          arr_def[j+1] = temp_def;
        }
      }
    }
    return (arr_addr,arr,arr_def);
  }
  function getTotalUsers()  external view returns (uint256) {
    return players.length;
  }
  function getMaxCap(address _addr,uint256 _cardId) external view returns (uint256) {
    return unitMaxCap[_addr][_cardId];
  }
  function getUnitsProduction(address player, uint256 unitId, uint256 amount) external constant returns (uint256) {
    return (amount * (schema.unitCoinProduction(unitId) + unitCoinProductionIncreases[player][unitId]) * (10 + unitCoinProductionMultiplier[player][unitId])) / 10; 
  } 
  function getUnitsInProduction(address player, uint256 unitId, uint256 amount) external constant returns (uint256) {
    return SafeMath.div(SafeMath.mul(amount,uintProduction[player][unitId]),unitsOwned[player][unitId]);
  } 
  function getUnitsAttack(address player, uint256 unitId, uint256 amount) internal constant returns (uint256) {
    return (amount * (schema.unitAttack(unitId) + unitAttackIncreases[player][unitId]) * (10 + unitAttackMultiplier[player][unitId])) / 10;
  }
  function getUnitsDefense(address player, uint256 unitId, uint256 amount) internal constant returns (uint256) {
    return (amount * (schema.unitDefense(unitId) + unitDefenseIncreases[player][unitId]) * (10 + unitDefenseMultiplier[player][unitId])) / 10;
  }
  function getUnitsStealingCapacity(address player, uint256 unitId, uint256 amount) internal constant returns (uint256) {
    return (amount * (schema.unitStealingCapacity(unitId) + unitJadeStealingIncreases[player][unitId]) * (10 + unitJadeStealingMultiplier[player][unitId])) / 10;
  }
  function getPlayersBattleStats(address player) public constant returns (
    uint256 attackingPower, 
    uint256 defendingPower, 
    uint256 stealingPower,
    uint256 battlePower) {
    uint256 startId;
    uint256 endId;
    (startId, endId) = schema.battleCardIdRange();
    while (startId <= endId) {
      attackingPower = SafeMath.add(attackingPower,getUnitsAttack(player, startId, unitsOwned[player][startId]));
      stealingPower = SafeMath.add(stealingPower,getUnitsStealingCapacity(player, startId, unitsOwned[player][startId]));
      defendingPower = SafeMath.add(defendingPower,getUnitsDefense(player, startId, unitsOwned[player][startId]));
      battlePower = SafeMath.add(attackingPower,defendingPower); 
      startId++;
    }
  }
  function getOwnedCount(address player, uint256 cardId) external view returns (uint256) {
    return unitsOwned[player][cardId];
  }
  function setOwnedCount(address player, uint256 cardId, uint256 amount, bool iflag) external onlyAccess {
    if (iflag) {
      unitsOwned[player][cardId] = SafeMath.add(unitsOwned[player][cardId],amount);
     } else if (!iflag) {
      unitsOwned[player][cardId] = SafeMath.sub(unitsOwned[player][cardId],amount);
    }
  }
  function getUpgradesOwned(address player, uint256 upgradeId) external view returns (uint256) {
    return upgradesOwned[player][upgradeId];
  }
  function setUpgradesOwned(address player, uint256 upgradeId) external onlyAccess {
    upgradesOwned[player][upgradeId] = SafeMath.add(upgradesOwned[player][upgradeId],1);
  }
  function getUintsOwnerCount(address _address) external view returns (uint256) {
    return uintsOwnerCount[_address];
  }
  function setUintsOwnerCount(address _address, uint256 amount, bool iflag) external onlyAccess {
    if (iflag) {
      uintsOwnerCount[_address] = SafeMath.add(uintsOwnerCount[_address],amount);
    } else if (!iflag) {
      uintsOwnerCount[_address] = SafeMath.sub(uintsOwnerCount[_address],amount);
    }
  }
  function getUnitCoinProductionIncreases(address _address, uint256 cardId) external view returns (uint256) {
    return unitCoinProductionIncreases[_address][cardId];
  }
  function setUnitCoinProductionIncreases(address _address, uint256 cardId, uint256 iValue,bool iflag) external onlyAccess {
    if (iflag) {
      unitCoinProductionIncreases[_address][cardId] = SafeMath.add(unitCoinProductionIncreases[_address][cardId],iValue);
    } else if (!iflag) {
      unitCoinProductionIncreases[_address][cardId] = SafeMath.sub(unitCoinProductionIncreases[_address][cardId],iValue);
    }
  }
  function getUnitCoinProductionMultiplier(address _address, uint256 cardId) external view returns (uint256) {
    return unitCoinProductionMultiplier[_address][cardId];
  }
  function setUnitCoinProductionMultiplier(address _address, uint256 cardId, uint256 iValue, bool iflag) external onlyAccess {
    if (iflag) {
      unitCoinProductionMultiplier[_address][cardId] = SafeMath.add(unitCoinProductionMultiplier[_address][cardId],iValue);
    } else if (!iflag) {
      unitCoinProductionMultiplier[_address][cardId] = SafeMath.sub(unitCoinProductionMultiplier[_address][cardId],iValue);
    }
  }
  function setUnitAttackIncreases(address _address, uint256 cardId, uint256 iValue,bool iflag) external onlyAccess {
    if (iflag) {
      unitAttackIncreases[_address][cardId] = SafeMath.add(unitAttackIncreases[_address][cardId],iValue);
    } else if (!iflag) {
      unitAttackIncreases[_address][cardId] = SafeMath.sub(unitAttackIncreases[_address][cardId],iValue);
    }
  }
  function getUnitAttackIncreases(address _address, uint256 cardId) external view returns (uint256) {
    return unitAttackIncreases[_address][cardId];
  } 
  function setUnitAttackMultiplier(address _address, uint256 cardId, uint256 iValue,bool iflag) external onlyAccess {
    if (iflag) {
      unitAttackMultiplier[_address][cardId] = SafeMath.add(unitAttackMultiplier[_address][cardId],iValue);
    } else if (!iflag) {
      unitAttackMultiplier[_address][cardId] = SafeMath.sub(unitAttackMultiplier[_address][cardId],iValue);
    }
  }
  function getUnitAttackMultiplier(address _address, uint256 cardId) external view returns (uint256) {
    return unitAttackMultiplier[_address][cardId];
  } 
  function setUnitDefenseIncreases(address _address, uint256 cardId, uint256 iValue,bool iflag) external onlyAccess {
    if (iflag) {
      unitDefenseIncreases[_address][cardId] = SafeMath.add(unitDefenseIncreases[_address][cardId],iValue);
    } else if (!iflag) {
      unitDefenseIncreases[_address][cardId] = SafeMath.sub(unitDefenseIncreases[_address][cardId],iValue);
    }
  }
  function getUnitDefenseIncreases(address _address, uint256 cardId) external view returns (uint256) {
    return unitDefenseIncreases[_address][cardId];
  }
  function setunitDefenseMultiplier(address _address, uint256 cardId, uint256 iValue,bool iflag) external onlyAccess {
    if (iflag) {
      unitDefenseMultiplier[_address][cardId] = SafeMath.add(unitDefenseMultiplier[_address][cardId],iValue);
    } else if (!iflag) {
      unitDefenseMultiplier[_address][cardId] = SafeMath.sub(unitDefenseMultiplier[_address][cardId],iValue);
    }
  }
  function getUnitDefenseMultiplier(address _address, uint256 cardId) external view returns (uint256) {
    return unitDefenseMultiplier[_address][cardId];
  }
  function setUnitJadeStealingIncreases(address _address, uint256 cardId, uint256 iValue,bool iflag) external onlyAccess {
    if (iflag) {
      unitJadeStealingIncreases[_address][cardId] = SafeMath.add(unitJadeStealingIncreases[_address][cardId],iValue);
    } else if (!iflag) {
      unitJadeStealingIncreases[_address][cardId] = SafeMath.sub(unitJadeStealingIncreases[_address][cardId],iValue);
    }
  }
  function getUnitJadeStealingIncreases(address _address, uint256 cardId) external view returns (uint256) {
    return unitJadeStealingIncreases[_address][cardId];
  } 
  function setUnitJadeStealingMultiplier(address _address, uint256 cardId, uint256 iValue,bool iflag) external onlyAccess {
    if (iflag) {
      unitJadeStealingMultiplier[_address][cardId] = SafeMath.add(unitJadeStealingMultiplier[_address][cardId],iValue);
    } else if (!iflag) {
      unitJadeStealingMultiplier[_address][cardId] = SafeMath.sub(unitJadeStealingMultiplier[_address][cardId],iValue);
    }
  }
  function getUnitJadeStealingMultiplier(address _address, uint256 cardId) external view returns (uint256) {
    return unitJadeStealingMultiplier[_address][cardId];
  } 
  function setUintCoinProduction(address _address, uint256 cardId, uint256 iValue, bool iflag) external onlyAccess {
    if (iflag) {
      uintProduction[_address][cardId] = SafeMath.add(uintProduction[_address][cardId],iValue);
     } else if (!iflag) {
      uintProduction[_address][cardId] = SafeMath.sub(uintProduction[_address][cardId],iValue);
    }
  }
  function getUintCoinProduction(address _address, uint256 cardId) external view returns (uint256) {
    return uintProduction[_address][cardId];
  }
  function upgradeUnitMultipliers(address player, uint256 upgradeClass, uint256 unitId, uint256 upgradeValue) external onlyAccess {
    uint256 productionGain;
    if (upgradeClass == 0) {
      unitCoinProductionIncreases[player][unitId] += upgradeValue;
      productionGain = unitsOwned[player][unitId] * upgradeValue * (10 + unitCoinProductionMultiplier[player][unitId]);
      increasePlayersJadeProduction(player, productionGain);
    } else if (upgradeClass == 1) {
      unitCoinProductionMultiplier[player][unitId] += upgradeValue;
      productionGain = unitsOwned[player][unitId] * upgradeValue * (schema.unitCoinProduction(unitId) + unitCoinProductionIncreases[player][unitId]);
      increasePlayersJadeProduction(player, productionGain);
    } else if (upgradeClass == 2) {
      unitAttackIncreases[player][unitId] += upgradeValue;
    } else if (upgradeClass == 3) {
      unitAttackMultiplier[player][unitId] += upgradeValue;
    } else if (upgradeClass == 4) {
      unitDefenseIncreases[player][unitId] += upgradeValue;
    } else if (upgradeClass == 5) {
      unitDefenseMultiplier[player][unitId] += upgradeValue;
    } else if (upgradeClass == 6) {
      unitJadeStealingIncreases[player][unitId] += upgradeValue;
    } else if (upgradeClass == 7) {
      unitJadeStealingMultiplier[player][unitId] += upgradeValue;
    } else if (upgradeClass == 8) {
      unitMaxCap[player][unitId] = upgradeValue;  
    }
  }
  function removeUnitMultipliers(address player, uint256 upgradeClass, uint256 unitId, uint256 upgradeValue) external onlyAccess {
    uint256 productionLoss;
    if (upgradeClass == 0) {
      unitCoinProductionIncreases[player][unitId] -= upgradeValue;
      productionLoss = unitsOwned[player][unitId] * upgradeValue * (10 + unitCoinProductionMultiplier[player][unitId]);
      reducePlayersJadeProduction(player, productionLoss);
    } else if (upgradeClass == 1) {
      unitCoinProductionMultiplier[player][unitId] -= upgradeValue;
      productionLoss = unitsOwned[player][unitId] * upgradeValue * (schema.unitCoinProduction(unitId) + unitCoinProductionIncreases[player][unitId]);
      reducePlayersJadeProduction(player, productionLoss);
    } else if (upgradeClass == 2) {
      unitAttackIncreases[player][unitId] -= upgradeValue;
    } else if (upgradeClass == 3) {
      unitAttackMultiplier[player][unitId] -= upgradeValue;
    } else if (upgradeClass == 4) {
      unitDefenseIncreases[player][unitId] -= upgradeValue;
    } else if (upgradeClass == 5) {
      unitDefenseMultiplier[player][unitId] -= upgradeValue;
    } else if (upgradeClass == 6) {
      unitJadeStealingIncreases[player][unitId] -= upgradeValue;
    } else if (upgradeClass == 7) {
      unitJadeStealingMultiplier[player][unitId] -= upgradeValue;
    }
  }
}
