contract ERC721Receiver {
    bytes4 public constant ERC721_RECEIVED = 0x150b7a02;
    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes _data
    )
        public
        returns(bytes4);
}
