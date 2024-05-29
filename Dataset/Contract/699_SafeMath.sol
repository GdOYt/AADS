contract SafeMath {
    function safeMul(uint a, uint b) pure internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }
    function safeSub(uint a, uint b) pure internal returns (uint) {
        assert(b <= a);
        return a - b;
    }
    function safeAdd(uint a, uint b) pure internal returns (uint) {
        uint c = a + b;
        assert(c>=a && c>=b);
        return c;
    }
}
