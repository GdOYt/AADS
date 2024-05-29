contract SafeMath {
    uint48 constant public MAX_UINT48 =
    0xFFFFFFFFFFFF;
    function safeAdd(uint48 x, uint48 y) constant internal returns (uint48 z) {
       require(x <= MAX_UINT48 - y);
        return x + y;
    }
    function safeSub(uint48 x, uint48 y) constant internal returns (uint48 z) {
        require(x > y);
        return x - y;
    }
    function safeMul(uint48 x, uint48 y) constant internal returns (uint48 z) {
        if (y == 0) return 0;
        require(x <= MAX_UINT48 / y);
        return x * y;
    }
}
