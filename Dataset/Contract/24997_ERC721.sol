contract ERC721 {
    function totalSupply() public view returns (uint256 total);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _tokenId) external;
    event Transfer(address from, address to, uint256 tokenId);
}
