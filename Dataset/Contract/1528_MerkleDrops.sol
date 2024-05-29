contract MerkleDrops is Pausable, Whitelist {
  bytes32 public rootHash;
  ERC20 public token;
  mapping(bytes32 => bool) public redeemed;
  constructor(bytes32 _rootHash, address _tokenAddress) {
    rootHash = _rootHash;
    token = ERC20(_tokenAddress);
    super.addAddressToWhitelist(msg.sender);
  }
  function constructLeaf(uint256 index, address recipient, uint256 amount) constant returns(bytes32) {
    bytes32 node = keccak256(abi.encodePacked(index, recipient, amount));
    return node;
  }
  function isProofValid(bytes32[] _proof, bytes32 _node) public constant returns(bool){
    bool isValid = MerkleProof.verifyProof(_proof, rootHash, _node);
    return isValid;
  }
  function redeemTokens(uint256 index , uint256 amount, bytes32[] _proof) whenNotPaused public returns(bool) {
    bytes32 node = constructLeaf(index, msg.sender, amount);
    require(!redeemed[node]);
    require(isProofValid(_proof, node));
    redeemed[node] = true;
    token.transfer(msg.sender, amount);
  }
  function withdrawTokens(ERC20 _token) public onlyIfWhitelisted(msg.sender) {
    token.transfer(msg.sender, _token.balanceOf(this));
  }
  function changeRoot(bytes32 _rootHash) public onlyIfWhitelisted(msg.sender) {
    rootHash = _rootHash;
  }
}
