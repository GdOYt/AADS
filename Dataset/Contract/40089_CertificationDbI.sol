contract CertificationDbI {
    event LogCertifierDbChanged(
        address indexed previousCertifierDb,
        address indexed newCertifierDb);
    event LogStudentCertified(
        address indexed student, uint timestamp,
        address indexed certifier, bytes32 indexed document);
    event LogStudentUncertified(
        address indexed student, uint timestamp,
        address indexed certifier);
    event LogCertificationDocumentAdded(
        address indexed student, bytes32 indexed document);
    event LogCertificationDocumentRemoved(
        address indexed student, bytes32 indexed document);
    function getCertifierDb()
        constant
        returns (address);
    function setCertifierDb(address newCertifierDb)
        returns (bool success);
    function certify(address student, bytes32 document)
        returns (bool success);
    function uncertify(address student)
        returns (bool success);
    function addCertificationDocument(address student, bytes32 document)
        returns (bool success);
    function addCertificationDocumentToSelf(bytes32 document)
        returns (bool success);
    function removeCertificationDocument(address student, bytes32 document)
        returns (bool success);
    function removeCertificationDocumentFromSelf(bytes32 document)
        returns (bool success);
    function getCertifiedStudentsCount()
        constant
        returns (uint count);
    function getCertifiedStudentAtIndex(uint index)
        payable
        returns (address student);
    function getCertification(address student)
        payable
        returns (bool certified, uint timestamp, address certifier, uint documentCount);
    function isCertified(address student)
        payable
        returns (bool isIndeed);
    function getCertificationDocumentAtIndex(address student, uint256 index)
        payable
        returns (bytes32 document);
    function isCertification(address student, bytes32 document)
        payable
        returns (bool isIndeed);
}
