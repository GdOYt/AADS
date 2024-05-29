contract Ownership {
    address public _owner;
    modifier onlyOwner() { require(msg.sender == _owner); _; }
    modifier validDestination( address to ) { require(to != address(0x0)); _; }
}
