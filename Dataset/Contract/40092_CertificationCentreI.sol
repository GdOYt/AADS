contract CertificationCentreI {
    event LogCertificationDbRegistered(address indexed db);
    event LogCertificationDbUnRegistered(address indexed db);
    function getCertificationDbCount()
        constant
        returns (uint);
    function getCertificationDbStatus(address db)
        constant
        returns (bool valid, uint256 index);
    function getCertificationDbAtIndex(uint256 index)
        constant
        returns (address db);
    function registerCertificationDb(address db)
        returns (bool success);
    function unRegisterCertificationDb(address db)
        returns (bool success);
}
