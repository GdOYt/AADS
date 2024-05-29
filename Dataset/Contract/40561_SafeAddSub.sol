contract SafeAddSub {
    function safeToAdd(uint a, uint b) internal returns (bool) {
        return (a + b > a);
    }
    function safeToSubtract(uint a, uint b) internal returns (bool) {
        return (a >= b);
    }
    function safeAdd(uint a, uint b) internal returns (uint256) {
        if (!safeToAdd(a, b)) throw;
        return a + b;
    }
    function safeSubtract(uint a, uint b) internal returns (uint256) {
        if (!safeToSubtract(a, b)) throw;
        return a - b;
    }
}
