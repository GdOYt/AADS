contract SafeDecimalMath {
    uint8 public constant decimals = 18;
    uint public constant UNIT = 10 ** uint(decimals);
    function addIsSafe(uint x, uint y)
        pure
        internal
        returns (bool)
    {
        return x + y >= y;
    }
    function safeAdd(uint x, uint y)
        pure
        internal
        returns (uint)
    {
        require(x + y >= y);
        return x + y;
    }
    function subIsSafe(uint x, uint y)
        pure
        internal
        returns (bool)
    {
        return y <= x;
    }
    function safeSub(uint x, uint y)
        pure
        internal
        returns (uint)
    {
        require(y <= x);
        return x - y;
    }
    function mulIsSafe(uint x, uint y)
        pure
        internal
        returns (bool)
    {
        if (x == 0) {
            return true;
        }
        return (x * y) / x == y;
    }
    function safeMul(uint x, uint y)
        pure
        internal
        returns (uint)
    {
        if (x == 0) {
            return 0;
        }
        uint p = x * y;
        require(p / x == y);
        return p;
    }
    function safeMul_dec(uint x, uint y)
        pure
        internal
        returns (uint)
    {
        return safeMul(x, y) / UNIT;
    }
    function divIsSafe(uint x, uint y)
        pure
        internal
        returns (bool)
    {
        return y != 0;
    }
    function safeDiv(uint x, uint y)
        pure
        internal
        returns (uint)
    {
        require(y != 0);
        return x / y;
    }
    function safeDiv_dec(uint x, uint y)
        pure
        internal
        returns (uint)
    {
        return safeDiv(safeMul(x, UNIT), y);
    }
    function intToDec(uint i)
        pure
        internal
        returns (uint)
    {
        return safeMul(i, UNIT);
    }
}
