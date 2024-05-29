contract ERC721Enumerable is ERC721Basic {
  bytes4 constant INTERFACE_ERC721_ENUMERABLE = 0x780e9d63;
  function totalSupply() public view returns (uint256);
  function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256 _tokenId);
  function tokenByIndex(uint256 _index) public view returns (uint256);
}
