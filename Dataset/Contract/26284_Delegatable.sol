contract Delegatable {
  address empty1;  
  address empty2;  
  address empty3;   
  address public owner;   
  address public delegation;  
  event DelegationTransferred(address indexed previousDelegate, address indexed newDelegation);
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  function transferDelegation(address newDelegation) public onlyOwner {
    require(newDelegation != address(0));
    DelegationTransferred(delegation, newDelegation);
    delegation = newDelegation;
  }
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}
