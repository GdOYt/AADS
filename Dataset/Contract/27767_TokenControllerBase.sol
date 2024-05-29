contract TokenControllerBase is RSTBase {
  function init() public;
  function isSellOpen() public constant returns(bool);
  function isBuyOpen() public constant returns(bool);
  function sell(uint value) public;
  function buy() public payable;
  function addToReserve() public payable;
}
