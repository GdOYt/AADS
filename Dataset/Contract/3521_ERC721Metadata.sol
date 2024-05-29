contract ERC721Metadata is ERC721Basic {
  bytes4 constant INTERFACE_ERC721_METADATA = 0x5b5e139f;
  function name() public view returns (string _name);
  function symbol() public view returns (string _symbol);
  function tokenURI(uint256 _tokenId) public view returns (string);
}
