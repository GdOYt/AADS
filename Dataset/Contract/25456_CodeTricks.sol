contract CodeTricks {
    function getCodeHash(address _addr) internal view returns (bytes32) {
        return keccak256(getCode(_addr));
    }
    function getCode(address _addr) internal view returns (bytes) {
        bytes memory code;
        assembly {
            let size := extcodesize(_addr)
            code := mload(0x40)
            mstore(0x40, add(code, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            mstore(code, size)
            extcodecopy(_addr, add(code, 0x20), 0, size)
        }
        return code;
    }
}
