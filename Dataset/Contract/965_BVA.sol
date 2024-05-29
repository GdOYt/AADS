contract BVA is Ownable, MintableToken {
  using SafeMath for uint256;    
  string public constant name = "BlockchainValley";
  string public constant symbol = "BVA";
  uint32 public constant decimals = 18;
  address public addressFounders;
  uint256 public summFounders;
  function BVA() public {
    addressFounders = 0x6e69307fe1fc55B2fffF680C5080774D117f1154;  
    summFounders = 35340000 * (10 ** uint256(decimals));  
    mint(addressFounders, summFounders);      
  }      
}
