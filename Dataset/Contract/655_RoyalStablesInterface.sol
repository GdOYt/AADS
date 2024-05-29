contract RoyalStablesInterface {
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
    function getOwnedTokens(address eth_address) public view returns (uint256[]);
    function storeName(uint256 tokenId, string newName) public;
    function storeCarrotsCredit(address client, uint32 amount) public;
    function storeHorsey(address client, uint256 tokenId, address race, bytes32 dna, uint8 feedingCounter, uint8 tier) public;
    function modifyHorsey(uint256 tokenId, address race, bytes32 dna, uint8 feedingCounter, uint8 tier) public;
    function modifyHorseyDna(uint256 tokenId, bytes32 dna) public;
    function modifyHorseyFeedingCounter(uint256 tokenId, uint8 feedingCounter) public;
    function modifyHorseyTier(uint256 tokenId, uint8 tier) public;
    function unstoreHorsey(uint256 tokenId) public;
    function ownerOf(uint256 tokenId) public returns (address);
}
