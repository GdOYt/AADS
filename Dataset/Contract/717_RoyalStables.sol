contract RoyalStables is Ownable,ERC721Token {
    struct Horsey {
        address race;       
        bytes32 dna;        
        uint8 feedingCounter;   
        uint8 tier;         
    }
    mapping(uint256 => Horsey) public horseys;
    mapping(address => uint32) public carrot_credits;
    mapping(uint256 => string) public names;
    address public master;
    constructor() public
    Ownable()
    ERC721Token("HORSEY","HRSY") {
    }
    function changeMaster(address newMaster) public
    validAddress(newMaster)
    onlyOwner() {
        master = newMaster;
    }
    function getOwnedTokens(address eth_address) public view returns (uint256[]) {
        return ownedTokens[eth_address];
    }
    function storeName(uint256 tokenId, string newName) public
    onlyMaster() {
        require(exists(tokenId),"token not found");
        names[tokenId] = newName;
    }
    function storeCarrotsCredit(address client, uint32 amount) public
    onlyMaster()
    validAddress(client) {
        carrot_credits[client] = amount;
    }
    function storeHorsey(address client, uint256 tokenId, address race, bytes32 dna, uint8 feedingCounter, uint8 tier) public
    onlyMaster()
    validAddress(client) {
        _mint(client,tokenId);
        modifyHorsey(tokenId,race,dna,feedingCounter,tier);
    }
    function modifyHorsey(uint256 tokenId, address race, bytes32 dna, uint8 feedingCounter, uint8 tier) public
    onlyMaster() {
        require(exists(tokenId),"token not found");
        Horsey storage hrsy = horseys[tokenId];
        hrsy.race = race;
        hrsy.dna = dna;
        hrsy.feedingCounter = feedingCounter;
        hrsy.tier = tier;
    }
    function modifyHorseyDna(uint256 tokenId, bytes32 dna) public
    onlyMaster() {
        require(exists(tokenId),"token not found");
        horseys[tokenId].dna = dna;
    }
    function modifyHorseyFeedingCounter(uint256 tokenId, uint8 feedingCounter) public
    onlyMaster() {
        require(exists(tokenId),"token not found");
        horseys[tokenId].feedingCounter = feedingCounter;
    }
    function modifyHorseyTier(uint256 tokenId, uint8 tier) public
    onlyMaster() {
        require(exists(tokenId),"token not found");
        horseys[tokenId].tier = tier;
    }
    function unstoreHorsey(uint256 tokenId) public
    onlyMaster()
    {
        require(exists(tokenId),"token not found");
        _burn(ownerOf(tokenId),tokenId);
        delete horseys[tokenId];
        delete names[tokenId];
    }
    modifier validAddress(address addr) {
        require(addr != address(0),"Address must be non zero");
        _;
    }
    modifier onlyMaster() {
        require(master == msg.sender,"Address must be non zero");
        _;
    }
}
