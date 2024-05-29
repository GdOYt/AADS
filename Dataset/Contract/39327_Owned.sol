contract Owned {
    address public owner;
    function setOwner(address _owner) onlyOwner
    { owner = _owner; }
    modifier onlyOwner { if (msg.sender != owner) throw; _; }
}
