contract XTVNetworkGuard {
  mapping(address => bool) xtvNetworkEndorser;
  modifier validateSignature(
    string memory message,
    bytes32 verificationHash,
    bytes memory xtvSignature
  ) {
    bytes32 xtvVerificationHash = keccak256(abi.encodePacked(verificationHash, message));
    require(verifyXTVSignature(xtvVerificationHash, xtvSignature));
    _;
  }
  function setXTVNetworkEndorser(address _addr, bool isEndorser) public;
  function verifyXTVSignature(bytes32 hash, bytes memory sig) public view returns (bool) {
    address signerAddress = XTVNetworkUtils.verifyXTVSignatureAddress(hash, sig);
    return xtvNetworkEndorser[signerAddress];
  }
}
