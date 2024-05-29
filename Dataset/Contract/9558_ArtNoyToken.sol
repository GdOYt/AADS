contract ArtNoyToken{
  function setCrowdsaleContract (address) public;
  function sendCrowdsaleTokens(address, uint256)  public;
  function getOwner()public view returns(address);
  function icoSucceed() public;
  function endIco () public;
}
