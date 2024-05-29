contract HorseyToken is EthorseHelpers,Pausable {
    using SafeMath for uint256;
    event Claimed(address raceAddress, address eth_address, uint256 tokenId);
    event Feeding(uint256 tokenId);
    event ReceivedCarrot(uint256 tokenId, bytes32 newDna);
    event FeedingFailed(uint256 tokenId);
    event HorseyRenamed(uint256 tokenId, string newName);
    event HorseyFreed(uint256 tokenId);
    RoyalStablesInterface public stables;
    uint8 public carrotsMultiplier = 1;
    uint8 public rarityMultiplier = 1;
    uint256 public claimingFee = 0.000 ether;
    struct FeedingData {
        uint256 blockNumber;     
        uint256 horsey;          
    }
    mapping(address => FeedingData) public pendingFeedings;
    uint256 public renamingCostsPerChar = 0.001 ether;
    constructor(address stablesAddress) 
    EthorseHelpers() 
    Pausable() public {
        stables = RoyalStablesInterface(stablesAddress);
    }
    function setRarityMultiplier(uint8 newRarityMultiplier) external 
    onlyOwner()  {
        rarityMultiplier = newRarityMultiplier;
    }
    function setCarrotsMultiplier(uint8 newCarrotsMultiplier) external 
    onlyOwner()  {
        carrotsMultiplier = newCarrotsMultiplier;
    }
    function setRenamingCosts(uint256 newRenamingCost) external 
    onlyOwner()  {
        renamingCostsPerChar = newRenamingCost;
    }
    function setClaimingCosts(uint256 newClaimingFee) external
    onlyOwner()  {
        claimingFee = newClaimingFee;
    }
    function addLegitRaceAddress(address newAddress) external
    onlyOwner() {
        _addLegitRace(newAddress);
    }
    function withdraw() external 
    onlyOwner()  {
        owner.transfer(address(this).balance);  
    }
    function addHorseIndex(bytes32 newHorse) external
    onlyOwner() {
        _addHorse(newHorse);
    }
    function getOwnedTokens(address eth_address) public view returns (uint256[]) {
        return stables.getOwnedTokens(eth_address);
    }
    function can_claim(address raceAddress, address eth_address) public view returns (bool) {
        bool res;
        (res,) = _isWinnerOf(raceAddress, eth_address);
        return res;
    }
    function claim(address raceAddress) external payable
    costs(claimingFee)
    whenNotPaused()
    {
        bytes32 winner;
        bool res;
        (res,winner) = _isWinnerOf(raceAddress, address(0));
        require(winner != bytes32(0),"Winner is zero");
        require(res,"can_claim return false");
        uint256 id = _generate_special_horsey(raceAddress, msg.sender, winner);
        emit Claimed(raceAddress, msg.sender, id);
    }
    function renameHorsey(uint256 tokenId, string newName) external 
    whenNotPaused()
    onlyOwnerOf(tokenId) 
    costs(renamingCostsPerChar * bytes(newName).length)
    payable {
        uint256 renamingFee = renamingCostsPerChar * bytes(newName).length;
        if(msg.value > renamingFee)  
        {
            msg.sender.transfer(msg.value.sub(renamingFee));
        }
        stables.storeName(tokenId,newName);
        emit HorseyRenamed(tokenId,newName);
    }
    function freeForCarrots(uint256 tokenId) external 
    whenNotPaused()
    onlyOwnerOf(tokenId) {
        require(pendingFeedings[msg.sender].horsey != tokenId,"");
        uint8 feedingCounter;
        (,,feedingCounter,) = stables.horseys(tokenId);
        stables.storeCarrotsCredit(msg.sender,stables.carrot_credits(msg.sender) + uint32(feedingCounter * carrotsMultiplier));
        stables.unstoreHorsey(tokenId);
        emit HorseyFreed(tokenId);
    }
    function getCarrotCredits() external view returns (uint32) {
        return stables.carrot_credits(msg.sender);
    }
    function getHorsey(uint256 tokenId) public view returns (address, bytes32, uint8, string) {
        RoyalStablesInterface.Horsey memory temp;
        (temp.race,temp.dna,temp.feedingCounter,temp.tier) = stables.horseys(tokenId);
        return (temp.race,temp.dna,temp.feedingCounter,stables.names(tokenId));
    }
    function feed(uint256 tokenId) external 
    whenNotPaused()
    onlyOwnerOf(tokenId) 
    carrotsMeetLevel(tokenId)
    noFeedingInProgress()
    {
        pendingFeedings[msg.sender] = FeedingData(block.number,tokenId);
        uint8 feedingCounter;
        (,,feedingCounter,) = stables.horseys(tokenId);
        stables.storeCarrotsCredit(msg.sender,stables.carrot_credits(msg.sender) - uint32(feedingCounter));
        emit Feeding(tokenId);
    }
    function stopFeeding() external
    feedingInProgress() returns (bool) {
        uint256 blockNumber = pendingFeedings[msg.sender].blockNumber;
        uint256 tokenId = pendingFeedings[msg.sender].horsey;
        require(block.number - blockNumber >= 1,"feeding and stop feeding are in same block");
        delete pendingFeedings[msg.sender];
        if(block.number - blockNumber > 255) {
            emit FeedingFailed(tokenId);
            return false; 
        }
        if(stables.ownerOf(tokenId) != msg.sender) {
            emit FeedingFailed(tokenId);
            return false; 
        }
        _feed(tokenId, blockhash(blockNumber));
        bytes32 dna;
        (,dna,,) = stables.horseys(tokenId);
        emit ReceivedCarrot(tokenId, dna);
        return true;
    }
    function() external payable {
        revert("Not accepting donations");
    }
    function _feed(uint256 tokenId, bytes32 blockHash) internal {
        uint8 tier;
        uint8 feedingCounter;
        (,,feedingCounter,tier) = stables.horseys(tokenId);
        uint256 probabilityByRarity = 10 ** (uint256(tier).add(1));
        uint256 randNum = uint256(keccak256(abi.encodePacked(tokenId, blockHash))) % probabilityByRarity;
        if(randNum <= (feedingCounter * rarityMultiplier)){
            _increaseRarity(tokenId, blockHash);
        }
        if(feedingCounter < 255) {
            stables.modifyHorseyFeedingCounter(tokenId,feedingCounter+1);
        }
    }
    function _makeSpecialId(address race, address sender, bytes32 coinIndex) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(race, sender, coinIndex)));
    }
    function _generate_special_horsey(address race, address eth_address, bytes32 coinIndex) internal returns (uint256) {
        uint256 id = _makeSpecialId(race, eth_address, coinIndex);
        bytes32 dna = _shiftRight(keccak256(abi.encodePacked(race, coinIndex)),16);
        stables.storeHorsey(eth_address,id,race,dna,1,0);
        return id;
    }
    function _increaseRarity(uint256 tokenId, bytes32 blockHash) private {
        uint8 tier;
        bytes32 dna;
        (,dna,,tier) = stables.horseys(tokenId);
        if(tier < 255)
            stables.modifyHorseyTier(tokenId,tier+1);
        uint256 random = uint256(keccak256(abi.encodePacked(tokenId, blockHash)));
        bytes32 rarityMask = _shiftLeft(bytes32(1), (random % 16 + 240));
        bytes32 newdna = dna | rarityMask;  
        stables.modifyHorseyDna(tokenId,newdna);
    }
    function _shiftLeft(bytes32 data, uint n) internal pure returns (bytes32) {
        return bytes32(uint256(data)*(2 ** n));
    }
    function _shiftRight(bytes32 data, uint n) internal pure returns (bytes32) {
        return bytes32(uint256(data)/(2 ** n));
    }
    modifier carrotsMeetLevel(uint256 tokenId){
        uint256 feedingCounter;
        (,,feedingCounter,) = stables.horseys(tokenId);
        require(feedingCounter <= stables.carrot_credits(msg.sender),"Not enough carrots");
        _;
    }
    modifier costs(uint256 amount) {
        require(msg.value >= amount,"Not enough funds");
        _;
    }
    modifier validAddress(address addr) {
        require(addr != address(0),"Address is zero");
        _;
    }
    modifier noFeedingInProgress() {
        require(pendingFeedings[msg.sender].blockNumber == 0,"Already feeding");
        _;
    }
    modifier feedingInProgress() {
        require(pendingFeedings[msg.sender].blockNumber != 0,"No pending feeding");
        _;
    }
    modifier onlyOwnerOf(uint256 tokenId) {
        require(stables.ownerOf(tokenId) == msg.sender, "Caller is not owner of this token");
        _;
    }
}
