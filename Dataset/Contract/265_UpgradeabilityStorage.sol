contract UpgradeabilityStorage {
    uint256 internal _version;
    address internal _implementation;
    function version() public view returns (uint256) {
        return _version;
    }
    function implementation() public view returns (address) {
        return _implementation;
    }
}
