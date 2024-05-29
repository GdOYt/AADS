contract CheckPayloadSize {
  modifier onlyPayloadSize(uint256 _size) {
    require(msg.data.length >= _size + 4);
    _;
  }
}
