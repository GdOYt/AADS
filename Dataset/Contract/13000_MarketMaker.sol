contract MarketMaker is ERC223Receiver {
  function getCurrentPrice() public constant returns (uint _price);
  function change(address _fromToken, uint _amount, address _toToken) public returns (uint _returnAmount);
  function change(address _fromToken, uint _amount, address _toToken, uint _minReturn) public returns (uint _returnAmount);
  function change(address _toToken) public returns (uint _returnAmount);
  function change(address _toToken, uint _minReturn) public returns (uint _returnAmount);
  function quote(address _fromToken, uint _amount, address _toToken) public constant returns (uint _returnAmount);
  function openForPublicTrade() public returns (bool success);
  function isOpenForPublic() public returns (bool success);
  event Change(address indexed fromToken, uint inAmount, address indexed toToken, uint returnAmount, address indexed account);
}
