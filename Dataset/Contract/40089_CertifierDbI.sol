contract CertifierDbI {
    event LogCertifierAdded(address indexed certifier);
    event LogCertifierRemoved(address indexed certifier);
    function addCertifier(address certifier)
        returns (bool success);
    function removeCertifier(address certifier)
        returns (bool success);
    function getCertifiersCount()
        constant
        returns (uint count);
    function getCertifierStatus(address certifierAddr)
        constant 
        returns (bool authorised, uint256 index);
    function getCertifierAtIndex(uint256 index)
        constant
        returns (address);
    function isCertifier(address certifier)
        constant
        returns (bool isIndeed);
}
