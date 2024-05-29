contract Owned is DBC {
    address public owner;
    function Owned() { owner = msg.sender; }
    function changeOwner(address ofNewOwner) pre_cond(isOwner()) { owner = ofNewOwner; }
    function isOwner() internal returns (bool) { return msg.sender == owner; }
}
