contract State is Owned {
    address public associatedContract;
    constructor(address _owner, address _associatedContract)
        Owned(_owner)
        public
    {
        associatedContract = _associatedContract;
        emit AssociatedContractUpdated(_associatedContract);
    }
    function setAssociatedContract(address _associatedContract)
        external
        onlyOwner
    {
        associatedContract = _associatedContract;
        emit AssociatedContractUpdated(_associatedContract);
    }
    modifier onlyAssociatedContract
    {
        require(msg.sender == associatedContract);
        _;
    }
    event AssociatedContractUpdated(address associatedContract);
}
