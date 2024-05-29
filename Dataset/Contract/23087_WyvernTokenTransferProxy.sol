contract WyvernTokenTransferProxy is TokenTransferProxy {
    function WyvernTokenTransferProxy (ProxyRegistry registryAddr)
        public
    {
        registry = registryAddr;
    }
}
