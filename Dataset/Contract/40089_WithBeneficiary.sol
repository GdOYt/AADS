contract WithBeneficiary is Owned {
    address private beneficiary;
    event LogBeneficiarySet(address indexed previousBeneficiary, address indexed newBeneficiary);
    function WithBeneficiary(address _beneficiary) payable {
        if (_beneficiary == 0) {
            throw;
        }
        beneficiary = _beneficiary;
        if (msg.value > 0) {
            asyncSend(beneficiary, msg.value);
        }
    }
    function asyncSend(address dest, uint amount) internal;
    function getBeneficiary()
        constant
        returns (address) {
        return beneficiary;
    }
    function setBeneficiary(address newBeneficiary)
        fromOwner 
        returns (bool success) {
        if (newBeneficiary == 0) {
            throw;
        }
        if (beneficiary != newBeneficiary) {
            LogBeneficiarySet(beneficiary, newBeneficiary);
            beneficiary = newBeneficiary;
        }
        success = true;
    }
    function () payable {
        asyncSend(beneficiary, msg.value);
    }
}
