contract BunnyGame is RabbitMarket {    
    function transferNewBunny(address _to, uint32 _bunnyid, uint localdnk, uint breed, uint32 matron, uint32 sire) internal {
        emit NewBunny(_bunnyid, localdnk, block.number, breed);
        emit CreateChildren(matron, sire, _bunnyid);
        addTokenList(_to, _bunnyid);
        totalSalaryBunny[_bunnyid] = 0;
        motherCount[_bunnyid] = 0;
        totalBunny++;
    }
    function createGennezise(uint32 _matron) public {
        bool promo = false;
        require(isPriv());
        require(isPauseSave());
        require(isPromoPause());
        if (totalGen0 > promoGen0) { 
            require(msg.sender == ownerServer || msg.sender == ownerCEO);
        } else if (!(msg.sender == ownerServer || msg.sender == ownerCEO)) {
                require(!ownerGennezise[msg.sender]);
                ownerGennezise[msg.sender] = true;
                promo = true;
        }
        uint  localdnk = privateContract.getNewRabbit(msg.sender);
        Rabbit memory _Rabbit =  Rabbit( 0, 0, block.number, 0, 0, 0, 0);
        uint32 _bunnyid =  uint32(rabbits.push(_Rabbit));
        mapDNK[_bunnyid] = localdnk;
        transferNewBunny(msg.sender, _bunnyid, localdnk, 0, 0, 0);  
        lastTimeGen0 = now;
        lastIdGen0 = _bunnyid; 
        totalGen0++; 
        setRabbitMother(_bunnyid, _matron);
        if (promo) {
            giffblock[_bunnyid] = true;
        }
    }
    function getGenomeChildren(uint32 _matron, uint32 _sire) internal view returns(uint) {
        uint genome;
        if (rabbits[(_matron-1)].genome >= rabbits[(_sire-1)].genome) {
            genome = rabbits[(_matron-1)].genome;
        } else {
            genome = rabbits[(_sire-1)].genome;
        }
        return genome.add(1);
    }
    function createChildren(uint32 _matron, uint32 _sire) public  payable returns(uint32) {
        require(isPriv());
        require(isPauseSave());
        require(rabbitToOwner[_matron] == msg.sender);
        require(rabbits[(_sire-1)].role == 1);
        require(_matron != _sire);
        require(getBreed(_matron));
        require(msg.value >= getSirePrice(_sire));
        uint genome = getGenomeChildren(_matron, _sire);
        uint localdnk =  privateContract.mixDNK(mapDNK[_matron], mapDNK[_sire], genome);
        Rabbit memory rabbit =  Rabbit(_matron, _sire, block.number, 0, 0, 0, genome);
        uint32 bunnyid =  uint32(rabbits.push(rabbit));
        mapDNK[bunnyid] = localdnk;
        uint _moneyMother = rabbitSirePrice[_sire].div(4);
        _transferMoneyMother(_matron, _moneyMother);
        rabbitToOwner[_sire].transfer(rabbitSirePrice[_sire]);
        uint system = rabbitSirePrice[_sire].div(100);
        system = system.mul(commission_system);
        ownerMoney.transfer(system);  
        coolduwnUP(_matron);
        transferNewBunny(rabbitToOwner[_matron], bunnyid, localdnk, genome, _matron, _sire);   
        setRabbitMother(bunnyid, _matron);
        return bunnyid;
    } 
    function coolduwnUP(uint32 _mother) internal { 
        require(isPauseSave());
        rabbits[(_mother-1)].birthCount = rabbits[(_mother-1)].birthCount.add(1);
        rabbits[(_mother-1)].birthLastTime = now;
        emit CoolduwnMother(_mother, rabbits[(_mother-1)].birthCount);
    }
    function _transferMoneyMother(uint32 _mother, uint _valueMoney) internal {
        require(isPauseSave());
        require(_valueMoney > 0);
        if (getRabbitMotherSumm(_mother) > 0) {
            uint pastMoney = _valueMoney/getRabbitMotherSumm(_mother);
            for (uint i=0; i < getRabbitMotherSumm(_mother); i++) {
                if (rabbitMother[_mother][i] != 0) { 
                    uint32 _parrentMother = rabbitMother[_mother][i];
                    address add = rabbitToOwner[_parrentMother];
                    setMotherCount(_parrentMother);
                    totalSalaryBunny[_parrentMother] += pastMoney;
                    emit SalaryBunny(_parrentMother, totalSalaryBunny[_parrentMother]);
                    add.transfer(pastMoney);  
                }
            } 
        }
    }
    function setRabbitSirePrice(uint32 _rabbitid, uint price) public returns(bool) {
        require(isPauseSave());
        require(rabbitToOwner[_rabbitid] == msg.sender);
        require(price > bigPrice);
        uint lastTime;
        (lastTime,,) = getcoolduwn(_rabbitid);
        require(now >= lastTime);
        if (rabbits[(_rabbitid-1)].role == 1 && rabbitSirePrice[_rabbitid] == price) {
            return false;
        }
        rabbits[(_rabbitid-1)].role = 1;
        rabbitSirePrice[_rabbitid] = price;
        uint gen = rabbits[(_rabbitid-1)].genome;
        sireGenom[gen].push(_rabbitid);
        emit ChengeSex(_rabbitid, true, getSirePrice(_rabbitid));
        return true;
    }
    function setSireStop(uint32 _rabbitid) public returns(bool) {
        require(isPauseSave());
        require(rabbitToOwner[_rabbitid] == msg.sender);
        rabbits[(_rabbitid-1)].role = 0;
        rabbitSirePrice[_rabbitid] = 0;
        deleteSire(_rabbitid);
        return true;
    }
      function deleteSire(uint32 _tokenId) internal { 
        uint gen = rabbits[(_tokenId-1)].genome;
        uint count = sireGenom[gen].length;
        for (uint i = 0; i < count; i++) {
            if(sireGenom[gen][i] == _tokenId)
            { 
                delete sireGenom[gen][i];
                if(count > 0 && count != (i-1)){
                    sireGenom[gen][i] = sireGenom[gen][(count-1)];
                    delete sireGenom[gen][(count-1)];
                } 
                sireGenom[gen].length--;
                emit ChengeSex(_tokenId, false, 0);
                return;
            } 
        }
    } 
    function getMoney(uint _value) public onlyOwner {
        require(address(this).balance >= _value);
        ownerMoney.transfer(_value);
    }
}
