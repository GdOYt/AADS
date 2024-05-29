contract MLBNFT {
    function exists(uint256 _tokenId) public view returns (bool _exists);
    function ownerOf(uint256 _tokenId) public view returns (address _owner);
    function approve(address _to, uint256 _tokenId) public;
    function setApprovalForAll(address _to, bool _approved) public;
    function transferFrom(address _from, address _to, uint256 _tokenId) public;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public;
    function createPromoCollectible(uint8 _teamId, uint8 _posId, uint256 _attributes, address _owner, uint256 _gameId, uint256 _playerOverrideId, uint256 _mlbPlayerId) external returns (uint256);
    function createSeedCollectible(uint8 _teamId, uint8 _posId, uint256 _attributes, address _owner, uint256 _gameId, uint256 _playerOverrideId, uint256 _mlbPlayerId) public returns (uint256);
    function checkIsAttached(uint256 _tokenId) public view returns (uint256);
    function getTeamId(uint256 _tokenId) external view returns (uint256);
    function getPlayerId(uint256 _tokenId) external view returns (uint256 playerId);
    function getApproved(uint256 _tokenId) public view returns (address _operator);
    function isApprovedForAll(address _owner, address _operator) public view returns (bool);
}
