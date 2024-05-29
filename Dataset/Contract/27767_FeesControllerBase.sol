contract FeesControllerBase is RSTBase {
  function init() public;
  function withdrawFee() public;
  function calculateFee() public;
  function addPayee( address payee ) public;
  function removePayee( address payee ) public;
  function setRepayment( ) payable public;
}
