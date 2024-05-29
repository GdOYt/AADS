contract Owned {
    address public owner;
    function Owned() { owner = msg.sender; }
    function delegate(address _owner) onlyOwner
    { owner = _owner; }
    modifier onlyOwner { if (msg.sender != owner) throw; _; }
}
