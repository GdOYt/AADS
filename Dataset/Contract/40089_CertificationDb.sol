contract CertificationDb is CertificationDbI, WithFee, PullPaymentCapable {
    CertifierDbI private certifierDb;
    struct DocumentStatus {
        bool isValid;
        uint256 index;
    }
    struct Certification {
        bool certified;
        uint256 timestamp;
        address certifier;
        mapping(bytes32 => DocumentStatus) documentStatuses;
        bytes32[] documents;
        uint256 index;
    }
    mapping(address => Certification) studentCertifications;
    address[] certifiedStudents;
    function CertificationDb(
            address beneficiary,
            uint256 certificationQueryFee,
            address _certifierDb)
            WithFee(beneficiary, certificationQueryFee) {
        if (msg.value > 0) {
            throw;
        }
        if (_certifierDb == 0) {
            throw;
        }
        certifierDb = CertifierDbI(_certifierDb);
    }
    modifier fromCertifier {
        if (!certifierDb.isCertifier(msg.sender)) {
            throw;
        }
        _;
    }
    function getCertifierDb()
        constant
        returns (address) {
        return certifierDb;
    }
    function setCertifierDb(address newCertifierDb)
        fromOwner
        returns (bool success) {
        if (newCertifierDb == 0) {
            throw;
        }
        if (certifierDb != newCertifierDb) {
            LogCertifierDbChanged(certifierDb, newCertifierDb);
            certifierDb = CertifierDbI(newCertifierDb);
        }
        success = true;
    }
    function certify(address student, bytes32 document) 
        fromCertifier
        returns (bool success) {
        if (student == 0 || studentCertifications[student].certified) {
            throw;
        }
        bool documentExists = document != 0;
        studentCertifications[student] = Certification({
            certified: true,
            timestamp: now,
            certifier: msg.sender,
            documents: new bytes32[](0),
            index: certifiedStudents.length
        });
        if (documentExists) {
            studentCertifications[student].documentStatuses[document] = DocumentStatus({
                isValid: true,
                index: studentCertifications[student].documents.length
            });
            studentCertifications[student].documents.push(document);
        }
        certifiedStudents.push(student);
        LogStudentCertified(student, now, msg.sender, document);
        success = true;
    }
    function uncertify(address student) 
        fromCertifier 
        returns (bool success) {
        if (!studentCertifications[student].certified
            || studentCertifications[student].documents.length > 0) {
            throw;
        }
        uint256 index = studentCertifications[student].index;
        delete studentCertifications[student];
        if (certifiedStudents.length > 1) {
            certifiedStudents[index] = certifiedStudents[certifiedStudents.length - 1];
            studentCertifications[certifiedStudents[index]].index = index;
        }
        certifiedStudents.length--;
        LogStudentUncertified(student, now, msg.sender);
        success = true;
    }
    function addCertificationDocument(address student, bytes32 document)
        fromCertifier
        returns (bool success) {
        success = addCertificationDocumentInternal(student, document);
    }
    function addCertificationDocumentToSelf(bytes32 document)
        returns (bool success) {
        success = addCertificationDocumentInternal(msg.sender, document);
    }
    function addCertificationDocumentInternal(address student, bytes32 document)
        internal
        returns (bool success) {
        if (!studentCertifications[student].certified
            || document == 0) {
            throw;
        }
        Certification certification = studentCertifications[student];
        if (!certification.documentStatuses[document].isValid) {
            certification.documentStatuses[document] = DocumentStatus({
                isValid:  true,
                index: certification.documents.length
            });
            certification.documents.push(document);
            LogCertificationDocumentAdded(student, document);
        }
        success = true;
    }
    function removeCertificationDocument(address student, bytes32 document)
        fromCertifier
        returns (bool success) {
        success = removeCertificationDocumentInternal(student, document);
    }
    function removeCertificationDocumentFromSelf(bytes32 document)
        returns (bool success) {
        success = removeCertificationDocumentInternal(msg.sender, document);
    }
    function removeCertificationDocumentInternal(address student, bytes32 document)
        internal
        returns (bool success) {
        if (!studentCertifications[student].certified) {
            throw;
        }
        Certification certification = studentCertifications[student];
        if (certification.documentStatuses[document].isValid) {
            uint256 index = certification.documentStatuses[document].index;
            delete certification.documentStatuses[document];
            if (certification.documents.length > 1) {
                certification.documents[index] =
                    certification.documents[certification.documents.length - 1];
                certification.documentStatuses[certification.documents[index]].index = index;
            }
            certification.documents.length--;
            LogCertificationDocumentRemoved(student, document);
        }
        success = true;
    }
    function getCertifiedStudentsCount()
        constant
        returns (uint256 count) {
        count = certifiedStudents.length;
    }
    function getCertifiedStudentAtIndex(uint256 index)
        payable
        requestFeePaid
        returns (address student) {
        student = certifiedStudents[index];
    }
    function getCertification(address student)
        payable
        requestFeePaid
        returns (bool certified, uint256 timestamp, address certifier, uint256 documentCount) {
        Certification certification = studentCertifications[student];
        return (certification.certified,
            certification.timestamp,
            certification.certifier,
            certification.documents.length);
    }
    function isCertified(address student)
        payable
        requestFeePaid
        returns (bool isIndeed) {
        isIndeed = studentCertifications[student].certified;
    }
    function getCertificationDocumentAtIndex(address student, uint256 index)
        payable
        requestFeePaid
        returns (bytes32 document) {
        document = studentCertifications[student].documents[index];
    }
    function isCertification(address student, bytes32 document)
        payable
        requestFeePaid
        returns (bool isIndeed) {
        isIndeed = studentCertifications[student].documentStatuses[document].isValid;
    }
    function fixBalance()
        returns (bool success) {
        return fixBalanceInternal(getBeneficiary());
    }
}
