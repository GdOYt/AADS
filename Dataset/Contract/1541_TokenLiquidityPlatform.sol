contract TokenLiquidityPlatform { 
  address public admin;
  modifier only_admin() {
      require(msg.sender == admin);
      _;
  }
  function TokenLiquidityPlatform() public { admin = msg.sender; }
  function create_a_new_market(address _traded_token, uint256 _base_token_seed_amount, uint256 _traded_token_seed_amount, uint256 _commission_ratio) public {
    new TokenLiquidityMarket(_traded_token, _base_token_seed_amount, _traded_token_seed_amount, _commission_ratio);
  }
  function withdraw_eth(uint256 _amount) public only_admin() {
    admin.transfer(_amount);  
  }
  function withdraw_token(address _token, uint256 _amount) public only_admin() {
    require(Token(_token).transfer(admin, _amount));
  }
  function() public payable {} 
}
