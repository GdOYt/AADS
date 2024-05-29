contract Ambi {
    function getNodeAddress(bytes32 _name) constant returns (address);
    function addNode(bytes32 _name, address _addr) external returns (bool);
    function hasRelation(bytes32 _from, bytes32 _role, address _to) constant returns (bool);
}
