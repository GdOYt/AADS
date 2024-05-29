contract SafeMath {
  function safeMul(uint256 a, uint256 b) internal returns (uint256 c) {
    c = a * b;
    assert(a == 0 || c / a == b);
  }
  function safeSub(uint256 a, uint256 b) internal returns (uint256 c) {
    assert(b <= a);
    c = a - b;
  }
  function safeAdd(uint256 a, uint256 b) internal returns (uint256 c) {
    c = a + b;
    assert(c>=a && c>=b);
  }
  function assert(bool assertion) internal {
    if (!assertion) throw;
  }
}
