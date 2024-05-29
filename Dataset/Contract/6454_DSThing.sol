contract DSThing is DSAuth, DSNote, DSMath {
    function S(string s) internal pure returns (bytes4) {
        return bytes4(keccak256(s));
    }
}
