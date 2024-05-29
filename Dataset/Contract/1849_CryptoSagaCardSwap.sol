contract CryptoSagaCardSwap is Ownable {
  address internal cardAddess;
  modifier onlyCard {
    require(msg.sender == cardAddess);
    _;
  }
  function setCardContract(address _contractAddress)
    public
    onlyOwner
  {
    cardAddess = _contractAddress;
  }
  function swapCardForReward(address _by, uint8 _rank)
    onlyCard
    public 
    returns (uint256);
}
