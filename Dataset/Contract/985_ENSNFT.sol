contract ENSNFT is ERC721Token {
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    Registrar registrar;
    constructor (string _name, string _symbol, address _registrar) public
        ERC721Token(_name, _symbol) {
        registrar = Registrar(_registrar);
    }
    function mint(bytes32 _hash) public {
        address deedAddress;
        (, deedAddress, , , ) = registrar.entries(_hash);
        Deed deed = Deed(deedAddress);
        require(deed.owner() == address(this));
        require(deed.previousOwner() == msg.sender);
        uint256 tokenId = uint256(_hash);  
        _mint(deed.previousOwner(), tokenId);
    }
    function burn(uint256 tokenId) {
        require(ownerOf(tokenId) == msg.sender);
        _burn(msg.sender, tokenId);
        registrar.transfer(bytes32(tokenId), msg.sender);
    }
}
