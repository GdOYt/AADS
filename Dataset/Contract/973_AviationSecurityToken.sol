contract AviationSecurityToken is SupportsInterfaceWithLookup, ERC721, ERC721BasicToken, Ownable {
    bytes4 private constant InterfaceId_ERC721Enumerable = 0x780e9d63;
    bytes4 private constant InterfaceId_ERC721Metadata = 0x5b5e139f;
    string public name_ = "AviationSecurityToken";
    string public symbol_ = "AVNS";
    mapping(address => uint256[]) internal ownedTokens;
    mapping(uint256 => uint256) internal ownedTokensIndex;
    uint256[] internal allTokens;
    mapping(uint256 => uint256) internal allTokensIndex;
    mapping(uint256 => string) internal tokenURIs;
    struct Data{
        string liscence;
        string URL;
    }
    mapping(uint256 => Data) internal tokenData;
    constructor() public {
        _registerInterface(InterfaceId_ERC721Enumerable);
        _registerInterface(InterfaceId_ERC721Metadata);
    }
    function mint(address _to, uint256 _id) external onlyManager {
        _mint(_to, _id);
    }
    function name() external view returns (string) {
        return name_;
    }
    function symbol() external view returns (string) {
        return symbol_;
    }
    function arrayOfTokensByAddress(address _holder) public view returns(uint256[]) {
        return ownedTokens[_holder];
    }
    function tokenURI(uint256 _tokenId) public view returns (string) {
        require(exists(_tokenId));
        return tokenURIs[_tokenId];
    }
    function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256) {
        require(_index < balanceOf(_owner));
        return ownedTokens[_owner][_index];
    }
    function totalSupply() public view returns (uint256) {
        return allTokens.length;
    }
    function tokenByIndex(uint256 _index) public view returns (uint256) {
        require(_index < totalSupply());
        return allTokens[_index];
    }
    function _setTokenURI(uint256 _tokenId, string _uri) internal {
        require(exists(_tokenId));
        tokenURIs[_tokenId] = _uri;
    }
    function addTokenTo(address _to, uint256 _tokenId) internal {
        super.addTokenTo(_to, _tokenId);
        uint256 length = ownedTokens[_to].length;
        ownedTokens[_to].push(_tokenId);
        ownedTokensIndex[_tokenId] = length;
    }
    function removeTokenFrom(address _from, uint256 _tokenId) internal {
        super.removeTokenFrom(_from, _tokenId);
        uint256 tokenIndex = ownedTokensIndex[_tokenId];
        uint256 lastTokenIndex = ownedTokens[_from].length.sub(1);
        uint256 lastToken = ownedTokens[_from][lastTokenIndex];
        ownedTokens[_from][tokenIndex] = lastToken;
        ownedTokens[_from][lastTokenIndex] = 0;
        ownedTokens[_from].length--;
        ownedTokensIndex[_tokenId] = 0;
        ownedTokensIndex[lastToken] = tokenIndex;
    }
    function _mint(address _to, uint256 _id) internal {
        allTokens.push(_id);
        allTokensIndex[_id] = _id;
        super._mint(_to, _id);
    }
    function addTokenData(uint _tokenId, string _liscence, string _URL) public {
            require(ownerOf(_tokenId) == msg.sender);
            tokenData[_tokenId].liscence = _liscence;
            tokenData[_tokenId].URL = _URL;
    }
    function getTokenData(uint _tokenId) public view returns(string Liscence, string URL){
        require(exists(_tokenId));
        Liscence = tokenData[_tokenId].liscence;
        URL = tokenData[_tokenId].URL;
    }
}
