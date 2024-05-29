contract CodexRecordProxy is ProxyOwnable {
  event Upgraded(string version, address indexed implementation);
  string public version;
  address public implementation;
  constructor(address _implementation) public {
    upgradeTo("1", _implementation);
  }
  function () payable public {
    address _implementation = implementation;
    assembly {
      let ptr := mload(0x40)
      calldatacopy(ptr, 0, calldatasize)
      let result := delegatecall(gas, _implementation, ptr, calldatasize, 0, 0)
      let size := returndatasize
      returndatacopy(ptr, 0, size)
      switch result
      case 0 { revert(ptr, size) }
      default { return(ptr, size) }
    }
  }
  function name() external view returns (string) {
    ERC721Metadata tokenMetadata = ERC721Metadata(implementation);
    return tokenMetadata.name();
  }
  function symbol() external view returns (string) {
    ERC721Metadata tokenMetadata = ERC721Metadata(implementation);
    return tokenMetadata.symbol();
  }
  function upgradeTo(string _version, address _implementation) public onlyOwner {
    require(
      keccak256(abi.encodePacked(_version)) != keccak256(abi.encodePacked(version)),
      "The version cannot be the same");
    require(
      _implementation != implementation,
      "The implementation cannot be the same");
    require(
      _implementation != address(0),
      "The implementation cannot be the 0 address");
    version = _version;
    implementation = _implementation;
    emit Upgraded(version, implementation);
  }
}
