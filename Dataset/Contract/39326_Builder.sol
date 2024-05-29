contract Builder is Object {
    event Builded(address indexed client, address indexed instance);
    mapping(address => address[]) public getContractsOf;
    function getLastContract() constant returns (address) {
        var sender_contracts = getContractsOf[msg.sender];
        return sender_contracts[sender_contracts.length - 1];
    }
    address public beneficiary;
    function setBeneficiary(address _beneficiary) onlyOwner
    { beneficiary = _beneficiary; }
    uint public buildingCostWei;
    function setCost(uint _buildingCostWei) onlyOwner
    { buildingCostWei = _buildingCostWei; }
    string public securityCheckURI;
    function setSecurityCheck(string _uri) onlyOwner
    { securityCheckURI = _uri; }
}
