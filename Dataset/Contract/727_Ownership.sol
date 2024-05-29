contract Ownership {
    address public owner;
    modifier onlyOwner() { require(msg.sender == owner); _; }
    modifier validDestination(address _targetAddress) { require(_targetAddress != address(0x0)); _; }
}
