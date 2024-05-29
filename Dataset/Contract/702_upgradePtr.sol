contract upgradePtr {
    address ptr = address(0);
    modifier not_upgraded() {
        require(ptr == address(0), "upgrade pointer is non-zero");
        _;
    }
    function getUpgradePointer() view external returns (address) {
        return ptr;
    }
    function doUpgradeInternal(address nextSC) internal {
        ptr = nextSC;
    }
}
