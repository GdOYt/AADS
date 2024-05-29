contract CertificationCentre is CertificationCentreI, WithBeneficiary, PullPaymentCapable {
    struct CertificationDbStruct {
        bool valid;
        uint256 index;
    }
    mapping (address => CertificationDbStruct) private certificationDbStatuses;
    address[] private certificationDbs;
    function CertificationCentre(address beneficiary)
        WithBeneficiary(beneficiary) {
        if (msg.value > 0) {
            throw;
        }
    }
    function getCertificationDbCount()
        constant
        returns (uint256) {
        return certificationDbs.length;
    }
    function getCertificationDbStatus(address db)
        constant
        returns (bool valid, uint256 index) {
        CertificationDbStruct status = certificationDbStatuses[db];
        return (status.valid, status.index);
    }
    function getCertificationDbAtIndex(uint256 index)
        constant
        returns (address db) {
        return certificationDbs[index];
    }
    function registerCertificationDb(address db) 
        fromOwner
        returns (bool success) {
        if (db == 0) {
            throw;
        }
        if (!certificationDbStatuses[db].valid) {
            certificationDbStatuses[db].valid = true;
            certificationDbStatuses[db].index = certificationDbs.length;
            certificationDbs.push(db);
        }
        LogCertificationDbRegistered(db);
        success = true;
    }
    function unRegisterCertificationDb(address db)
        fromOwner
        returns (bool success) {
        if (certificationDbStatuses[db].valid) {
            uint256 index = certificationDbStatuses[db].index;
            certificationDbs[index] = certificationDbs[certificationDbs.length - 1];
            certificationDbStatuses[certificationDbs[index]].index = index;
            delete certificationDbStatuses[db];
            certificationDbs.length--;
        }
        LogCertificationDbUnRegistered(db);
        success = true;
    }
    function fixBalance()
        returns (bool success) {
        return fixBalanceInternal(getBeneficiary());
    }
}
