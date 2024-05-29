contract Ownable {
    address  owner;
    function Ownable() public{
        owner = msg.sender;
    }
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) onlyOwner public{
        assert(newOwner != address(0));
        owner = newOwner;
    }
}
