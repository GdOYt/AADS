contract safeMath {
	function safeSub(uint a, uint b) constant internal returns(uint) {
		assert(b <= a);
		return a - b;
	}
	function safeAdd(uint a, uint b) constant internal returns(uint) {
		uint c = a + b;
		assert(c >= a && c >= b);
		return c;
	}
	function safeMul(uint a, uint b) constant internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
}
