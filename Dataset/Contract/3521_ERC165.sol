contract ERC165 {
  bytes4 constant INTERFACE_ERC165 = 0x01ffc9a7;
  function supportsInterface(bytes4 _interfaceID) public pure returns (bool) {
    return _interfaceID == INTERFACE_ERC165;
  }
}
