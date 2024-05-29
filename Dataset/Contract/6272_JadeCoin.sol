contract JadeCoin is ERC20, AccessAdmin {
  using SafeMath for SafeMath;
  string public constant name  = "MAGICACADEMY JADE";
  string public constant symbol = "Jade";
  uint8 public constant decimals = 0;
  uint256 public roughSupply;
  uint256 public totalJadeProduction;
  uint256[] public totalJadeProductionSnapshots;  
  uint256 public nextSnapshotTime;
  uint256 public researchDivPercent = 10;
  mapping(address => uint256) public jadeBalance;
  mapping(address => mapping(uint8 => uint256)) public coinBalance;
  mapping(uint8 => uint256) totalEtherPool;  
  mapping(address => mapping(uint256 => uint256)) public jadeProductionSnapshots;  
  mapping(address => mapping(uint256 => bool)) private jadeProductionZeroedSnapshots;  
  mapping(address => uint256) public lastJadeSaveTime;  
  mapping(address => uint256) public lastJadeProductionUpdate;  
  mapping(address => uint256) private lastJadeResearchFundClaim;  
  mapping(address => uint256) private lastJadeDepositFundClaim;  
  uint256[] private allocatedJadeResearchSnapshots;  
  mapping(address => mapping(address => uint256)) private allowed;
  event ReferalGain(address player, address referal, uint256 amount);
  function JadeCoin() public {
  }
  function() external payable {
    totalEtherPool[1] += msg.value;
  }
  function tweakDailyDividends(uint256 newResearchPercent) external {
    require(msg.sender == owner);
    require(newResearchPercent > 0 && newResearchPercent <= 10);
    researchDivPercent = newResearchPercent;
  }
  function totalSupply() public constant returns(uint256) {
    return roughSupply;  
  }
  function balanceOf(address player) public constant returns(uint256) {
    return SafeMath.add(jadeBalance[player],balanceOfUnclaimed(player));
  }
  function balanceOfUnclaimed(address player) public constant returns (uint256) {
    uint256 lSave = lastJadeSaveTime[player];
    if (lSave > 0 && lSave < block.timestamp) { 
      return SafeMath.mul(getJadeProduction(player),SafeMath.div(SafeMath.sub(block.timestamp,lSave),10));
    }
    return 0;
  }
  function getJadeProduction(address player) public constant returns (uint256){
    return jadeProductionSnapshots[player][lastJadeProductionUpdate[player]];
  }
  function getTotalJadeProduction() external view returns (uint256) {
    return totalJadeProduction;
  }
  function getlastJadeProductionUpdate(address player) public view returns (uint256) {
    return lastJadeProductionUpdate[player];
  }
  function increasePlayersJadeProduction(address player, uint256 increase) public onlyAccess {
    jadeProductionSnapshots[player][allocatedJadeResearchSnapshots.length] = SafeMath.add(getJadeProduction(player),increase);
    lastJadeProductionUpdate[player] = allocatedJadeResearchSnapshots.length;
    totalJadeProduction = SafeMath.add(totalJadeProduction,increase);
  }
  function reducePlayersJadeProduction(address player, uint256 decrease) public onlyAccess {
    uint256 previousProduction = getJadeProduction(player);
    uint256 newProduction = SafeMath.sub(previousProduction, decrease);
    if (newProduction == 0) { 
      jadeProductionZeroedSnapshots[player][allocatedJadeResearchSnapshots.length] = true;
      delete jadeProductionSnapshots[player][allocatedJadeResearchSnapshots.length];  
    } else {
      jadeProductionSnapshots[player][allocatedJadeResearchSnapshots.length] = newProduction;
    }   
    lastJadeProductionUpdate[player] = allocatedJadeResearchSnapshots.length;
    totalJadeProduction = SafeMath.sub(totalJadeProduction,decrease);
  }
  function updatePlayersCoin(address player) internal {
    uint256 coinGain = balanceOfUnclaimed(player);
    lastJadeSaveTime[player] = block.timestamp;
    roughSupply = SafeMath.add(roughSupply,coinGain);  
    jadeBalance[player] = SafeMath.add(jadeBalance[player],coinGain);  
  }
  function updatePlayersCoinByOut(address player) external onlyAccess {
    uint256 coinGain = balanceOfUnclaimed(player);
    lastJadeSaveTime[player] = block.timestamp;
    roughSupply = SafeMath.add(roughSupply,coinGain);  
    jadeBalance[player] = SafeMath.add(jadeBalance[player],coinGain);  
  }
  function transfer(address recipient, uint256 amount) public returns (bool) {
    updatePlayersCoin(msg.sender);
    require(amount <= jadeBalance[msg.sender]);
    jadeBalance[msg.sender] = SafeMath.sub(jadeBalance[msg.sender],amount);
    jadeBalance[recipient] = SafeMath.add(jadeBalance[recipient],amount);
    Transfer(msg.sender, recipient, amount);
    return true;
  }
  function transferFrom(address player, address recipient, uint256 amount) public returns (bool) {
    updatePlayersCoin(player);
    require(amount <= allowed[player][msg.sender] && amount <= jadeBalance[player]);
    jadeBalance[player] = SafeMath.sub(jadeBalance[player],amount); 
    jadeBalance[recipient] = SafeMath.add(jadeBalance[recipient],amount); 
    allowed[player][msg.sender] = SafeMath.sub(allowed[player][msg.sender],amount); 
    Transfer(player, recipient, amount);  
    return true;
  }
  function approve(address approvee, uint256 amount) public returns (bool) {
    allowed[msg.sender][approvee] = amount;  
    Approval(msg.sender, approvee, amount);
    return true;
  }
  function allowance(address player, address approvee) public constant returns(uint256) {
    return allowed[player][approvee];  
  }
  function updatePlayersCoinByPurchase(address player, uint256 purchaseCost) public onlyAccess {
    uint256 unclaimedJade = balanceOfUnclaimed(player);
    if (purchaseCost > unclaimedJade) {
      uint256 jadeDecrease = SafeMath.sub(purchaseCost, unclaimedJade);
      require(jadeBalance[player] >= jadeDecrease);
      roughSupply = SafeMath.sub(roughSupply,jadeDecrease);
      jadeBalance[player] = SafeMath.sub(jadeBalance[player],jadeDecrease);
    } else {
      uint256 jadeGain = SafeMath.sub(unclaimedJade,purchaseCost);
      roughSupply = SafeMath.add(roughSupply,jadeGain);
      jadeBalance[player] = SafeMath.add(jadeBalance[player],jadeGain);
    }
    lastJadeSaveTime[player] = block.timestamp;
  }
  function JadeCoinMining(address _addr, uint256 _amount) external onlyAdmin {
    roughSupply = SafeMath.add(roughSupply,_amount);
    jadeBalance[_addr] = SafeMath.add(jadeBalance[_addr],_amount);
  }
  function setRoughSupply(uint256 iroughSupply) external onlyAccess {
    roughSupply = SafeMath.add(roughSupply,iroughSupply);
  }
  function coinBalanceOf(address player,uint8 itype) external constant returns(uint256) {
    return coinBalance[player][itype];
  }
  function setJadeCoin(address player, uint256 coin, bool iflag) external onlyAccess {
    if (iflag) {
      jadeBalance[player] = SafeMath.add(jadeBalance[player],coin);
    } else if (!iflag) {
      jadeBalance[player] = SafeMath.sub(jadeBalance[player],coin);
    }
  }
  function setCoinBalance(address player, uint256 eth, uint8 itype, bool iflag) external onlyAccess {
    if (iflag) {
      coinBalance[player][itype] = SafeMath.add(coinBalance[player][itype],eth);
    } else if (!iflag) {
      coinBalance[player][itype] = SafeMath.sub(coinBalance[player][itype],eth);
    }
  }
  function setLastJadeSaveTime(address player) external onlyAccess {
    lastJadeSaveTime[player] = block.timestamp;
  }
  function setTotalEtherPool(uint256 inEth, uint8 itype, bool iflag) external onlyAccess {
    if (iflag) {
      totalEtherPool[itype] = SafeMath.add(totalEtherPool[itype],inEth);
     } else if (!iflag) {
      totalEtherPool[itype] = SafeMath.sub(totalEtherPool[itype],inEth);
    }
  }
  function getTotalEtherPool(uint8 itype) external view returns (uint256) {
    return totalEtherPool[itype];
  }
  function setJadeCoinZero(address player) external onlyAccess {
    jadeBalance[player]=0;
  }
  function getNextSnapshotTime() external view returns(uint256) {
    return nextSnapshotTime;
  }
  function viewUnclaimedResearchDividends() external constant returns (uint256, uint256, uint256) {
    uint256 startSnapshot = lastJadeResearchFundClaim[msg.sender];
    uint256 latestSnapshot = allocatedJadeResearchSnapshots.length - 1;  
    uint256 researchShare;
    uint256 previousProduction = jadeProductionSnapshots[msg.sender][lastJadeResearchFundClaim[msg.sender] - 1];  
    for (uint256 i = startSnapshot; i <= latestSnapshot; i++) {     
      uint256 productionDuringSnapshot = jadeProductionSnapshots[msg.sender][i];
      bool soldAllProduction = jadeProductionZeroedSnapshots[msg.sender][i];
      if (productionDuringSnapshot == 0 && !soldAllProduction) {
        productionDuringSnapshot = previousProduction;
      } else {
        previousProduction = productionDuringSnapshot;
    }
      researchShare += (allocatedJadeResearchSnapshots[i] * productionDuringSnapshot) / totalJadeProductionSnapshots[i];
    }
    return (researchShare, startSnapshot, latestSnapshot);
  }
  function claimResearchDividends(address referer, uint256 startSnapshot, uint256 endSnapShot) external {
    require(startSnapshot <= endSnapShot);
    require(startSnapshot >= lastJadeResearchFundClaim[msg.sender]);
    require(endSnapShot < allocatedJadeResearchSnapshots.length);
    uint256 researchShare;
    uint256 previousProduction = jadeProductionSnapshots[msg.sender][lastJadeResearchFundClaim[msg.sender] - 1];  
    for (uint256 i = startSnapshot; i <= endSnapShot; i++) {
      uint256 productionDuringSnapshot = jadeProductionSnapshots[msg.sender][i];
      bool soldAllProduction = jadeProductionZeroedSnapshots[msg.sender][i];
      if (productionDuringSnapshot == 0 && !soldAllProduction) {
        productionDuringSnapshot = previousProduction;
      } else {
        previousProduction = productionDuringSnapshot;
      }
      researchShare += (allocatedJadeResearchSnapshots[i] * productionDuringSnapshot) / totalJadeProductionSnapshots[i];
      }
    if (jadeProductionSnapshots[msg.sender][endSnapShot] == 0 && !jadeProductionZeroedSnapshots[msg.sender][endSnapShot] && previousProduction > 0) {
      jadeProductionSnapshots[msg.sender][endSnapShot] = previousProduction;  
    }
    lastJadeResearchFundClaim[msg.sender] = endSnapShot + 1;
    uint256 referalDivs;
    if (referer != address(0) && referer != msg.sender) {
      referalDivs = researchShare / 100;  
      coinBalance[referer][1] += referalDivs;
      ReferalGain(referer, msg.sender, referalDivs);
    }
    coinBalance[msg.sender][1] += SafeMath.sub(researchShare,referalDivs);
  }    
  function snapshotDailyGooResearchFunding() external onlyAdmin {
    uint256 todaysGooResearchFund = (totalEtherPool[1] * researchDivPercent) / 100;  
    totalEtherPool[1] -= todaysGooResearchFund;
    totalJadeProductionSnapshots.push(totalJadeProduction);
    allocatedJadeResearchSnapshots.push(todaysGooResearchFund);
    nextSnapshotTime = block.timestamp + 24 hours;
  }
}
