contract Identity {
  struct DAVIdentity {
    address wallet;
  }
  mapping (address => DAVIdentity) private identities;
  DAVToken private token;
  bytes28 private constant ETH_SIGNED_MESSAGE_PREFIX = '\x19Ethereum Signed Message:\n32';
  bytes25 private constant DAV_REGISTRATION_REQUEST = 'DAV Identity Registration';
  function Identity(DAVToken _davTokenContract) public {
    token = _davTokenContract;
  }
  function register(address _id, uint8 _v, bytes32 _r, bytes32 _s) public {
    require(
      identities[_id].wallet == 0x0
    );
    bytes32 prefixedHash = keccak256(ETH_SIGNED_MESSAGE_PREFIX, keccak256(DAV_REGISTRATION_REQUEST));
    require(
      ecrecover(prefixedHash, _v, _r, _s) == _id
    );
    identities[_id] = DAVIdentity({
      wallet: msg.sender
    });
  }
  function registerSimple() public {
    require(
      identities[msg.sender].wallet == 0x0
    );
    identities[msg.sender] = DAVIdentity({
      wallet: msg.sender
    });
  }
  function getBalance(address _id) public view returns (uint256 balance) {
    return token.balanceOf(identities[_id].wallet);
  }
  function verifyOwnership(address _id, address _wallet) public view returns (bool verified) {
    return identities[_id].wallet == _wallet;
  }
  function isRegistered(address _id) public view returns (bool) {
    return identities[_id].wallet != 0x0;
  }
  function getIdentityWallet(address _id) public view returns (address) {
    return identities[_id].wallet;
  }
}
