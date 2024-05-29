contract Presale is AccessService, Random {
    ELHeroToken tokenContract;
    mapping (uint16 => uint16) public cardPresaleCounter;
    mapping (address => uint16[]) OwnerToPresale;
    uint256 public jackpotBalance;
    event CardPreSelled(address indexed buyer, uint16 protoId);
    event Jackpot(address indexed _winner, uint256 _value, uint16 _type);
    constructor(address _nftAddr) public {
        addrAdmin = msg.sender;
        addrService = msg.sender;
        addrFinance = msg.sender;
        tokenContract = ELHeroToken(_nftAddr);
        cardPresaleCounter[1] = 20;  
        cardPresaleCounter[2] = 20;  
        cardPresaleCounter[3] = 20;  
        cardPresaleCounter[4] = 20;  
        cardPresaleCounter[5] = 20;  
        cardPresaleCounter[6] = 20;  
        cardPresaleCounter[7] = 20;  
        cardPresaleCounter[8] = 20;  
        cardPresaleCounter[9] = 20;
        cardPresaleCounter[10] = 20;
        cardPresaleCounter[11] = 20; 
        cardPresaleCounter[12] = 20;
        cardPresaleCounter[13] = 20;
        cardPresaleCounter[14] = 20;
        cardPresaleCounter[15] = 20;
        cardPresaleCounter[16] = 20; 
        cardPresaleCounter[17] = 20;
        cardPresaleCounter[18] = 20;
        cardPresaleCounter[19] = 20;
        cardPresaleCounter[20] = 20;
        cardPresaleCounter[21] = 20; 
        cardPresaleCounter[22] = 20;
        cardPresaleCounter[23] = 20;
        cardPresaleCounter[24] = 20;
        cardPresaleCounter[25] = 20;
    }
    function() external payable {
        require(msg.value > 0);
        jackpotBalance += msg.value;
    }
    function setELHeroTokenAddr(address _nftAddr) external onlyAdmin {
        tokenContract = ELHeroToken(_nftAddr);
    }
    function cardPresale(uint16 _protoId) external payable whenNotPaused{
        uint16 curSupply = cardPresaleCounter[_protoId];
        require(curSupply > 0);
        require(msg.value == 0.25 ether);
        uint16[] storage buyArray = OwnerToPresale[msg.sender];
        uint16[5] memory param = [10000 + _protoId, _protoId, 6, 0, 1];
        tokenContract.createCard(msg.sender, param, 1);
        buyArray.push(_protoId);
        cardPresaleCounter[_protoId] = curSupply - 1;
        emit CardPreSelled(msg.sender, _protoId);
        jackpotBalance += msg.value * 2 / 10;
        addrFinance.transfer(address(this).balance - jackpotBalance);
        uint256 seed = _rand();
        if(seed % 100 == 99){
            emit Jackpot(msg.sender, jackpotBalance, 2);
            msg.sender.transfer(jackpotBalance);
        }
    }
    function withdraw() external {
        require(msg.sender == addrFinance || msg.sender == addrAdmin);
        addrFinance.transfer(address(this).balance);
    }
    function getCardCanPresaleCount() external view returns (uint16[25] cntArray) {
        cntArray[0] = cardPresaleCounter[1];
        cntArray[1] = cardPresaleCounter[2];
        cntArray[2] = cardPresaleCounter[3];
        cntArray[3] = cardPresaleCounter[4];
        cntArray[4] = cardPresaleCounter[5];
        cntArray[5] = cardPresaleCounter[6];
        cntArray[6] = cardPresaleCounter[7];
        cntArray[7] = cardPresaleCounter[8];
        cntArray[8] = cardPresaleCounter[9];
        cntArray[9] = cardPresaleCounter[10];
        cntArray[10] = cardPresaleCounter[11];
        cntArray[11] = cardPresaleCounter[12];
        cntArray[12] = cardPresaleCounter[13];
        cntArray[13] = cardPresaleCounter[14];
        cntArray[14] = cardPresaleCounter[15];
        cntArray[15] = cardPresaleCounter[16];
        cntArray[16] = cardPresaleCounter[17];
        cntArray[17] = cardPresaleCounter[18];
        cntArray[18] = cardPresaleCounter[19];
        cntArray[19] = cardPresaleCounter[20];
        cntArray[20] = cardPresaleCounter[21];
        cntArray[21] = cardPresaleCounter[22];
        cntArray[22] = cardPresaleCounter[23];
        cntArray[23] = cardPresaleCounter[24];
        cntArray[24] = cardPresaleCounter[25];
    }
    function getBuyCount(address _owner) external view returns (uint32) {
        return uint32(OwnerToPresale[_owner].length);
    }
    function getBuyArray(address _owner) external view returns (uint16[]) {
        uint16[] storage buyArray = OwnerToPresale[_owner];
        return buyArray;
    }
    function eventPirze(address _addr, uint8 _id) public onlyAdmin{
        require(_id == 20 || _id == 21);
        uint16 curSupply = cardPresaleCounter[_id];
        require(curSupply > 0);
        uint16[] storage buyArray = OwnerToPresale[_addr];
        uint16[5] memory param = [10000 + _id, _id, 6, 0, 1];
        tokenContract.createCard(_addr, param, 1);
        buyArray.push(_id);
        cardPresaleCounter[_id] = curSupply - 1;
    }
}
