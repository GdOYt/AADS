contract WINECrowdsale is Ownable, Crowdsale {
  constructor(address _wallet, ERC20 _token) public Crowdsale(_wallet, _token){
  }
  modifier validAddress(address _address) {
      require(_address != 0x0);
      _;
  }
  modifier notThis(address _address) {
      require(_address != address(this));
      _;
  }
  function withdrawTokens(ERC20 _token, address _to, uint256 _amount) public onlyOwner validAddress(_token) validAddress(_to) notThis(_to)
  {
      assert(_token.transfer(_to, _amount));
  }
  function setNewWallet(address _newWallet) public onlyOwner {
      require(_newWallet != address(0));
      wallet = _newWallet;
  }
}
