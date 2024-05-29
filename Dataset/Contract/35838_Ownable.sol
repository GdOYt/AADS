contract Ownable {
    address public owner;
    address public newOwner;
    function Ownable() {
        owner = msg.sender;
    }
    modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
    modifier validAddress(address _address) {
        require(_address != 0x0);
        _;
    }
    function transferOwnership(address _newOwner) onlyOwner {
        if (_newOwner != address(0)) {
            owner = _newOwner;
        }
    }
    function acceptOwnership() {
        require(msg.sender == newOwner);
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
    event OwnershipTransferred(address indexed _from, address indexed _to);
}
