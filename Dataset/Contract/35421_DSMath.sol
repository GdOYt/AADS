contract DSMath {
    function hmore(uint128 x, uint128 y) constant internal returns (bool) {
        return x>y;
    }
    function hless(uint128 x, uint128 y) constant internal returns (bool) {
        return x<y;
    }
    function hadd(uint128 x, uint128 y) constant internal returns (uint128 z) {
        require((z = x + y) >= x);
    }
    function hsub(uint128 x, uint128 y) constant internal returns (uint128 z) {
        require((z = x - y) <= x);
    }
    function hmul(uint128 x, uint128 y) constant internal returns (uint128 z) {
        require(y == 0 ||(z = x * y)/ y == x);
    }
    function hdiv(uint128 x, uint128 y) constant internal returns (uint128 z) {
        z = x / y;
    }
    function hmin(uint128 x, uint128 y) constant internal returns (uint128 z) {
        return x <= y ? x : y;
    }
    function hmax(uint128 x, uint128 y) constant internal returns (uint128 z) {
        return x >= y ? x : y;
    }
    uint64 constant WAD_Dec=18;
    uint128 constant WAD = 10 ** 18;
    function wmore(uint128 x, uint128 y) constant internal returns (bool) {
        return hmore(x, y);
    }
    function wless(uint128 x, uint128 y) constant internal returns (bool) {
        return hless(x, y);
    }
    function wadd(uint128 x, uint128 y) constant  returns (uint128) {
        return hadd(x, y);
    }
    function wsub(uint128 x, uint128 y) constant   returns (uint128) {
        return hsub(x, y);
    }
    function wmul(uint128 x, uint128 y) constant returns (uint128 z) {
        z = cast((uint256(x) * y + WAD / 2) / WAD);
    }
    function wdiv(uint128 x, uint128 y) constant internal  returns (uint128 z) {
        z = cast((uint256(x) * WAD + y / 2) / y);
    }
    function wmin(uint128 x, uint128 y) constant internal  returns (uint128) {
        return hmin(x, y);
    }
    function wmax(uint128 x, uint128 y) constant internal  returns (uint128) {
        return hmax(x, y);
    }
    function cast(uint256 x) constant internal returns (uint128 z) {
        assert((z = uint128(x)) == x);
    }
}
