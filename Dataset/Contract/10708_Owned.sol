contract Owned {
    address public owner;
    address public nominatedOwner;
    constructor(address _owner)
        public
    {
        require(_owner != address(0));
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }
    function nominateNewOwner(address _owner)
        external
        onlyOwner
    {
        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }
    function acceptOwnership()
        external
    {
        require(msg.sender == nominatedOwner);
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }
    modifier onlyOwner
    {
        require(msg.sender == owner);
        _;
    }
    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}
