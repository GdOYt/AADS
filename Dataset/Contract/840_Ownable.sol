contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  function Ownable() public {
    owner = msg.sender;}
  modifier onlyOwner() {
    require(msg.sender == owner); _; } }
