contract casino is mortal{
  uint public minimumBet;
  uint public maximumBet;
  mapping(address => bool) public authorized;
  function casino(uint minBet, uint maxBet) public{
    minimumBet = minBet;
    maximumBet = maxBet;
  }
  function setMinimumBet(uint newMin) onlyOwner public{
    minimumBet = newMin;
  }
  function setMaximumBet(uint newMax) onlyOwner public{
    maximumBet = newMax;
  }
  function authorize(address addr) onlyOwner public{
    authorized[addr] = true;
  }
  function deauthorize(address addr) onlyOwner public{
    authorized[addr] = false;
  }
  modifier onlyAuthorized{
    require(authorized[msg.sender]);
    _;
  }
}
