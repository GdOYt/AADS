contract SafeMath {
    function safeToAdd(uint a, uint b) pure internal returns (bool) {
        return (a + b >= a);
    }
    function safeAdd(uint a, uint b) pure internal returns (uint) {
        require(safeToAdd(a, b));
        return a + b;
    }
    function safeToSubtract(uint a, uint b) pure internal returns (bool) {
        return (b <= a);
    }
    function safeSub(uint a, uint b) pure internal returns (uint) {
        require(safeToSubtract(a, b));
        return a - b;
    }
}
