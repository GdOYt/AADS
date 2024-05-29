contract CheckIfContract {
  function isContract(address _addr) view internal returns (bool) {
    uint256 length;
    if (_addr == address(0x0)) return false;
    assembly {
      length := extcodesize(_addr)
    }
    if(length > 0) {
      return true;
    } else {
      return false;
    }
  }
}
