contract Owned {
    address public contractOwner;
    address public pendingContractOwner;
    function Owned() {
        contractOwner = msg.sender;
    }
    modifier onlyContractOwner() {
        if (contractOwner == msg.sender) {
            _;
        }
    }
    function destroy() onlyContractOwner {
        suicide(msg.sender);
    }
    function changeContractOwnership(address _to) onlyContractOwner() returns(bool) {
        if (_to  == 0x0) {
            return false;
        }
        pendingContractOwner = _to;
        return true;
    }
    function claimContractOwnership() returns(bool) {
        if (pendingContractOwner != msg.sender) {
            return false;
        }
        contractOwner = pendingContractOwner;
        delete pendingContractOwner;
        return true;
    }
}
