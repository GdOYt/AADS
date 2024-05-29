contract BodyRabbit is BaseRabbit, ERC721 {
    uint public totalBunny = 0;
    string public constant name = "CryptoRabbits";
    string public constant symbol = "CRB";
    PrivateRabbitInterface privateContract;
    function setPriv(address _privAddress) public returns(bool) {
        privAddress = _privAddress;
        privateContract = PrivateRabbitInterface(_privAddress);
    } 
    bool public fcontr = false;
    constructor() public { 
        setPriv(myAddr_test);
        fcontr = true;
    }
    function isPriv() public view returns(bool) {
        return privateContract.isUIntPrivate();
    }
    modifier checkPrivate() {
        require(isPriv());
        _;
    }
    function ownerOf(uint32 _tokenId) public view returns (address owner) {
        return rabbitToOwner[_tokenId];
    }
    function approve(address _to, uint32 _tokenId) public returns (bool) { 
        _to;
        _tokenId;
        return false;
    }
    function removeTokenList(address _owner, uint32 _tokenId) internal { 
        uint count = ownerBunnies[_owner].length;
        for (uint256 i = 0; i < count; i++) {
            if(ownerBunnies[_owner][i] == _tokenId)
            { 
                delete ownerBunnies[_owner][i];
                if(count > 0 && count != (i-1)){
                    ownerBunnies[_owner][i] = ownerBunnies[_owner][(count-1)];
                    delete ownerBunnies[_owner][(count-1)];
                } 
                ownerBunnies[_owner].length--;
                return;
            } 
        }
    }
    function getSirePrice(uint32 _tokenId) public view returns(uint) {
        if(rabbits[(_tokenId-1)].role == 1){
            uint procent = (rabbitSirePrice[_tokenId] / 100);
            uint res = procent.mul(25);
            uint system  = procent.mul(commission_system);
            res = res.add(rabbitSirePrice[_tokenId]);
            return res.add(system); 
        } else {
            return 0;
        }
    }
    function addTokenList(address owner,  uint32 _tokenId) internal {
        ownerBunnies[owner].push( _tokenId);
        emit OwnerBunnies(owner, _tokenId);
        rabbitToOwner[_tokenId] = owner; 
    }
    function transfer(address _to, uint32 _tokenId) public {
        address currentOwner = msg.sender;
        address oldOwner = rabbitToOwner[_tokenId];
        require(rabbitToOwner[_tokenId] == msg.sender);
        require(currentOwner != _to);
        require(_to != address(0));
        removeTokenList(oldOwner, _tokenId);
        addTokenList(_to, _tokenId);
        emit Transfer(oldOwner, _to, _tokenId);
    }
    function transferFrom(address _from, address _to, uint32 _tokenId) public returns(bool) {
        address oldOwner = rabbitToOwner[_tokenId];
        require(oldOwner == _from);
        require(oldOwner != _to);
        require(_to != address(0));
        removeTokenList(oldOwner, _tokenId);
        addTokenList(_to, _tokenId); 
        emit Transfer (oldOwner, _to, _tokenId);
        return true;
    }  
    function setTimeRangeGen0(uint _sec) public onlyOwner {
        timeRangeCreateGen0 = _sec;
    }
    function isPauseSave() public view returns(bool) {
        return !pauseSave;
    }
    function isPromoPause() public view returns(bool) {
        if(msg.sender == ownerServer || msg.sender == ownerCEO){
            return true;
        }else{
            return !promoPause;
        } 
    }
    function setPauseSave() public onlyOwner  returns(bool) {
        return pauseSave = !pauseSave;
    }
    function isUIntPublic() public pure returns(bool) {
        return true;
    }
    function getTokenOwner(address owner) public view returns(uint total, uint32[] list) {
        total = ownerBunnies[owner].length;
        list = ownerBunnies[owner];
    } 
    function setRabbitMother(uint32 children, uint32 mother) internal { 
        require(children != mother);
        if (mother == 0 )
        {
            return;
        }
        uint32[11] memory pullMother;
        uint start = 0;
        for (uint i = 0; i < 5; i++) {
            if (rabbitMother[mother][i] != 0) {
              pullMother[start] = uint32(rabbitMother[mother][i]);
              rabbitMother[mother][i] = 0;
              start++;
            } 
        }
        pullMother[start] = mother;
        start++;
        for (uint m = 0; m < 5; m++) {
             if(start >  5){
                    rabbitMother[children][m] = pullMother[(m+1)];
             }else{
                    rabbitMother[children][m] = pullMother[m];
             }
        } 
        setMotherCount(mother);
    }
    function setMotherCount(uint32 _mother) internal returns(uint)  {  
        motherCount[_mother] = motherCount[_mother].add(1);
        emit EmotherCount(_mother, motherCount[_mother]);
        return motherCount[_mother];
    }
     function getMotherCount(uint32 _mother) public view returns(uint) {  
        return  motherCount[_mother];
    }
     function getTotalSalaryBunny(uint32 _bunny) public view returns(uint) {  
        return  totalSalaryBunny[_bunny];
    }
    function getRabbitMother( uint32 mother) public view returns(uint32[5]){
        return rabbitMother[mother];
    }
     function getRabbitMotherSumm(uint32 mother) public view returns(uint count) {  
        for (uint m = 0; m < 5 ; m++) {
            if(rabbitMother[mother][m] != 0 ) { 
                count++;
            }
        }
    }
    function getRabbitDNK(uint32 bunnyid) public view returns(uint) { 
        return mapDNK[bunnyid];
    }
    function bytes32ToString(bytes32 x)internal pure returns (string) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }
    function uintToBytes(uint v) internal pure returns (bytes32 ret) {
        if (v == 0) {
            ret = '0';
        } else {
        while (v > 0) {
                ret = bytes32(uint(ret) / (2 ** 8));
                ret |= bytes32(((v % 10) + 48) * 2 ** (8 * 31));
                v /= 10;
            }
        }
        return ret;
    }
    function totalSupply() public view returns (uint total) {
        return totalBunny;
    }
    function balanceOf(address _owner) public view returns (uint) {
        return ownerBunnies[_owner].length;
    }
    function sendMoney(address _to, uint256 _money) internal { 
        _to.transfer((_money/100)*95);
        ownerMoney.transfer((_money/100)*5); 
    }
    function getGiffBlock(uint32 _bunnyid) public view returns(bool) { 
        return !giffblock[_bunnyid];
    }
    function getOwnerGennezise(address _to) public view returns(bool) { 
        return ownerGennezise[_to];
    }
    function getBunny(uint32 _bunny) public view returns(
        uint32 mother,
        uint32 sire,
        uint birthblock,
        uint birthCount,
        uint birthLastTime,
        uint role, 
        uint genome,
        bool interbreed,
        uint leftTime,
        uint lastTime,
        uint price,
        uint motherSumm
        )
        {
            price = getSirePrice(_bunny);
            _bunny = _bunny - 1;
            mother = rabbits[_bunny].mother;
            sire = rabbits[_bunny].sire;
            birthblock = rabbits[_bunny].birthblock;
            birthCount = rabbits[_bunny].birthCount;
            birthLastTime = rabbits[_bunny].birthLastTime;
            role = rabbits[_bunny].role;
            genome = rabbits[_bunny].genome;
            if(birthCount > 14) {
                birthCount = 14;
            }
            motherSumm = motherCount[_bunny];
            lastTime = uint(cooldowns[birthCount]);
            lastTime = lastTime.add(birthLastTime);
            if(lastTime <= now) {
                interbreed = true;
            } else {
                leftTime = lastTime.sub(now);
            }
    }
    function getBreed(uint32 _bunny) public view returns(
        bool interbreed
        )
        {
        _bunny = _bunny - 1;
        if(_bunny == 0) {
            return;
        }
        uint birtTime = rabbits[_bunny].birthLastTime;
        uint birthCount = rabbits[_bunny].birthCount;
        uint  lastTime = uint(cooldowns[birthCount]);
        lastTime = lastTime.add(birtTime);
        if(lastTime <= now && rabbits[_bunny].role == 0 ) {
            interbreed = true;
        } 
    }
    function getcoolduwn(uint32 _mother) public view returns(uint lastTime, uint cd, uint lefttime) {
        cd = rabbits[(_mother-1)].birthCount;
        if(cd > 14) {
            cd = 14;
        }
        lastTime = (cooldowns[cd] + rabbits[(_mother-1)].birthLastTime);
        if(lastTime > now) {
            lefttime = lastTime.sub(now);
        }
    }
}
