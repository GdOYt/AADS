contract UpgradeabilityProxy is Proxy, UpgradeabilityStorage {
    event Upgraded(uint256 version, address indexed implementation);
    function _upgradeTo(uint256 version, address implementation) internal {
        require(_implementation != implementation);
        require(version > _version);
        _version = version;
        _implementation = implementation;
        emit Upgraded(version, implementation);
    }
}
