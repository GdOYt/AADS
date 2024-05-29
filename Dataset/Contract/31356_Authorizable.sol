contract Authorizable is Ownable {
  mapping(address => bool) public authorized;
  event AuthorizationSet(address indexed addressAuthorized, bool indexed authorization);
  function Authorizable() public {
	authorized[msg.sender] = true;
  }
  modifier onlyAuthorized() {
    require(authorized[msg.sender]);
    _;
  }
  function setAuthorized(address addressAuthorized, bool authorization) onlyOwner public {
    AuthorizationSet(addressAuthorized, authorization);
    authorized[addressAuthorized] = authorization;
  }
}
