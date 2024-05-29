contract SafeMath {
    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        assert(c >= _a); 
        return c;
    }
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        assert(_a >= _b); 
        return _a - _b;
    }
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a * _b;
        assert(_a == 0 || c / _a == _b); 
        return c;
    }
}
