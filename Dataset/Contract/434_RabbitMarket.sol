contract RabbitMarket is BodyRabbit {
    uint stepMoney = 2*60*60;
    function setStepMoney(uint money) public onlyOwner {
        stepMoney = money;
    }
    uint marketCount = 0; 
    uint daysperiod = 1;
    uint sec = 1;
    uint8 middlelast = 20;
    mapping(uint32 => uint256[]) internal marketRabbits;
    uint256 middlePriceMoney = 1; 
    uint256 middleSaleTime = 0;  
    uint moneyRange;
    function setMoneyRange(uint _money) public onlyOwner {
        moneyRange = _money;
    }
    uint lastmoney = 0;  
    uint lastTimeGen0;
    uint public totalClosedBID = 0;
    mapping (uint32 => uint) bunnyCost; 
    mapping(uint32 => uint) bidsIndex;
    function currentPrice(uint32 _bunnyid) public view returns(uint) {
        uint money = bunnyCost[_bunnyid];
        if (money > 0) {
            uint moneyComs = money.div(100);
            moneyComs = moneyComs.mul(5);
            return money.add(moneyComs);
        }
    }
  function startMarket(uint32 _bunnyid, uint _money) public returns (uint) {
        require(isPauseSave());
        require(_money >= bigPrice);
        require(rabbitToOwner[_bunnyid] ==  msg.sender);
        bunnyCost[_bunnyid] = _money;
        emit StartMarket(_bunnyid, _money);
        return marketCount++;
    }
    function stopMarket(uint32 _bunnyid) public returns(uint) {
        require(isPauseSave());
        require(rabbitToOwner[_bunnyid] == msg.sender);  
        bunnyCost[_bunnyid] = 0;
        emit StopMarket(_bunnyid);
        return marketCount--;
    }
    function buyBunny(uint32 _bunnyid) public payable {
        require(isPauseSave());
        require(rabbitToOwner[_bunnyid] != msg.sender);
        uint price = currentPrice(_bunnyid);
        require(msg.value >= price && 0 != price);
        totalClosedBID++;
        sendMoney(rabbitToOwner[_bunnyid], msg.value);
        transferFrom(rabbitToOwner[_bunnyid], msg.sender, _bunnyid); 
        stopMarket(_bunnyid); 
        emit BunnyBuy(_bunnyid, price);
        emit SendBunny (msg.sender, _bunnyid);
    } 
    function giff(uint32 bunnyid, address add) public {
        require(rabbitToOwner[bunnyid] == msg.sender);
        require(!(giffblock[bunnyid]));
        transferFrom(msg.sender, add, bunnyid);
    }
    function getMarketCount() public view returns(uint) {
        return marketCount;
    }
}
