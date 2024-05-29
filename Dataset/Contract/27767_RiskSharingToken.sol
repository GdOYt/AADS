contract RiskSharingToken is RSTBase {
  string public constant version = "0.1";
  string public constant name = "REGA Risk Sharing Token";
  string public constant symbol = "RST";
  uint8 public constant decimals = 10;
  TokenControllerBase public tokenController;
  VotingControllerBase public votingController;
  FeesControllerBase public feesController;
  modifier ownerOnly() {
    require( msg.sender == owner );
    _;
  }
  modifier boardOnly() {
    require( msg.sender == board );
    _;
  }
  modifier authorized() {
    require( msg.sender == owner || msg.sender == board);
    _;
  }
  function RiskSharingToken( address _board ) {
    board = _board;
    owner = msg.sender;
    tokenController = TokenControllerBase(0);
    votingController = VotingControllerBase(0);
    weiForToken = uint(10)**(18-1-decimals);  
    reserve = 0;
    crr = 20;
    totalAccounts = 0;
  }
  function() payable {
  }
  function setTokenController( TokenControllerBase tc, address _tokenData ) public boardOnly {
    tokenController = tc;
    if( _tokenData != address(0) )
      tokenData = _tokenData;
    if( tokenController != TokenControllerBase(0) )
      if( !tokenController.delegatecall(bytes4(sha3("init()"))) )
        revert();
  }
  function setVotingController( VotingControllerBase vc ) public boardOnly {
    votingController = vc;
  }
  function startVoting( bytes32   ) public boardOnly validAddress(votingController) {
    if( !votingController.delegatecall(msg.data) )
      revert();
  }
  function stopVoting() public boardOnly validAddress(votingController) {
    if( !votingController.delegatecall(msg.data) )
      revert();
  }
  function voteFor() public validAddress(votingController) {
    if( !votingController.delegatecall(msg.data) )
      revert();
  }
  function voteAgainst() public validAddress(votingController) {
    if( !votingController.delegatecall(msg.data) )
      revert();
  }
  function buy() public payable validAddress(tokenController) {
    if( !tokenController.delegatecall(msg.data) )
      revert();
  }
  function sell( uint   ) public validAddress(tokenController) {
    if( !tokenController.delegatecall(msg.data) )
      revert();
  }
  function addToReserve( ) public payable validAddress(tokenController) {
    if( !tokenController.delegatecall(msg.data) )
      revert();
  }
  function withdraw( uint256 amount ) public boardOnly {
    require(safeSub(this.balance, amount) >= reserve);
    board.transfer( amount );
  }
  function issueToken( address  , uint256   ) public authorized {
    if( !tokenController.delegatecall(msg.data) )
      revert();
  }
  function issueTokens( uint256[]   ) public ownerOnly {
    if( !tokenController.delegatecall(msg.data) )
      revert();
  }
  function setFeesController( FeesControllerBase fc ) public boardOnly {
    feesController = fc;
    if( !feesController.delegatecall(bytes4(sha3("init()"))) )
      revert();
  }
  function withdrawFee() public validAddress(feesController) {
      if( !feesController.delegatecall(msg.data) )
        revert();
  }
  function calculateFee() public validAddress(feesController) {
      if( !feesController.delegatecall(msg.data) )
        revert();
  }
  function addPayee( address   ) public validAddress(feesController) {
      if( !feesController.delegatecall(msg.data) )
        revert();
  }
  function removePayee( address   ) public validAddress(feesController) {
      if( !feesController.delegatecall(msg.data) )
        revert();
  }
  function setRepayment( ) payable public validAddress(feesController) {
      if( !feesController.delegatecall(msg.data) )
        revert();
  }
}
