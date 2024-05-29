contract Ownable {
    address public owner;
    address public creater;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function Ownable(address _owner) public {
        creater = msg.sender;
        if (_owner != 0) {
            owner = _owner;
        }
        else {
            owner = creater;
        }
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    modifier isCreator() {
        require(msg.sender == creater);
        _;
    }
}
