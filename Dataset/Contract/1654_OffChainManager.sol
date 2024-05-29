contract OffChainManager {
    function isToOffChainAddress(address addr) constant returns (bool);
    function getOffChainRootAddress() constant returns (address);
}
