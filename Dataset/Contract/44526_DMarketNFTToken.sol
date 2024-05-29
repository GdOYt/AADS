contract DMarketNFTToken is MinterAccess, ERC721 {
    string private _baseTokenURI;
    constructor (address newOwner, string memory tokenURIPrefix) ERC721("DMarket NFT Swap", "DM NFT") {
        transferOwnership(newOwner);
        grantRole(DEFAULT_ADMIN_ROLE, newOwner);
        _baseTokenURI = tokenURIPrefix;
    }
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }
    function burn(uint256 tokenID) public virtual {
        require(_isApprovedOrOwner(_msgSender(), tokenID), "DMarketNFTToken: caller is not owner nor approved");
        _burn(tokenID);
    }
    function mintToken(address to, uint64 tokenID) public virtual onlyMinter {
        _mint(to, tokenID);
    }
    function mintTokenBatch(address[] memory receivers, uint64[] memory tokenIDs) public virtual onlyMinter {
        require(receivers.length > 0,"DMarketNFTToken: must be some receivers");
        require(receivers.length == tokenIDs.length, "DMarketNFTToken: must be the same number of receivers/tokenIDs");
        for (uint64 i = 0; i < receivers.length; i++) {
            address to = receivers[i];
            uint256 tokenID = tokenIDs[i];
            _mint(to, tokenID);
        }
    }
}
