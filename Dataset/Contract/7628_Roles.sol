contract Roles {
    address public superAdmin ;
    address public canary ; 
    mapping (address => bool) public initiators ; 
    mapping (address => bool) public validators ;  
    address[] validatorsAcct ; 
    uint public qtyInitiators ; 
    uint constant public maxValidators = 20 ; 
    uint public qtyValidators ; 
    event superAdminOwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event initiatorAdded(address indexed newInitiator);
    event validatorAdded(address indexed newValidator);
    event initiatorRemoved(address indexed removedInitiator);
    event validatorRemoved(address indexed addedValidator);
    event canaryOwnershipTransferred(address indexed previousOwner, address indexed newOwner) ; 
    constructor() public 
    { 
      superAdmin = msg.sender ;
    }
    modifier onlySuperAdmin {
        require( msg.sender == superAdmin );
        _;
    }
    modifier onlyCanary {
        require( msg.sender == canary );
        _;
    }
    modifier onlyInitiators {
        require( initiators[msg.sender] );
        _;
    }
    modifier onlyValidators {
        require( validators[msg.sender] );
        _;
    }
function transferSuperAdminOwnership(address newOwner) public onlySuperAdmin 
{
  require(newOwner != address(0)) ;
  superAdmin = newOwner ;
  emit superAdminOwnershipTransferred(superAdmin, newOwner) ;  
}
function transferCanaryOwnership(address newOwner) public onlySuperAdmin 
{
  require(newOwner != address(0)) ;
  canary = newOwner ;
  emit canaryOwnershipTransferred(canary, newOwner) ;  
}
function addValidator(address _validatorAddr) public onlySuperAdmin 
{
  require(_validatorAddr != address(0));
  require(!validators[_validatorAddr]) ; 
  validators[_validatorAddr] = true ; 
  validatorsAcct.push(_validatorAddr) ; 
  qtyValidators++ ; 
  emit validatorAdded(_validatorAddr) ;  
}
function revokeValidator(address _validatorAddr) public onlySuperAdmin
{
  require(_validatorAddr != address(0));
  require(validators[_validatorAddr]) ; 
  validators[_validatorAddr] = false ; 
  for(uint i = 0 ; i < qtyValidators ; i++ ) 
    {
      if (validatorsAcct[i] == _validatorAddr)
         validatorsAcct[i] = address(0) ; 
    }
  qtyValidators-- ; 
  emit validatorRemoved(_validatorAddr) ;  
}
function addInitiator(address _initiatorAddr) public onlySuperAdmin
{
  require(_initiatorAddr != address(0));
  require(!initiators[_initiatorAddr]) ;
  initiators[_initiatorAddr] = true ; 
  qtyInitiators++ ; 
  emit initiatorAdded(_initiatorAddr) ; 
}
function revokeInitiator(address _initiatorAddr) public onlySuperAdmin
{
  require(_initiatorAddr != address(0));
  require(initiators[_initiatorAddr]) ; 
  initiators[_initiatorAddr] = false ;
  qtyInitiators-- ; 
  emit initiatorRemoved(_initiatorAddr) ; 
}
}  
