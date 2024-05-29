contract Ambi {
    function getNodeAddress(bytes32) constant returns(address);
    function addNode(bytes32, address) external returns(bool);    
    function hasRelation(bytes32, bytes32, address) constant returns(bool);
}
