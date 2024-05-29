contract VotingControllerBase is RSTBase {
  function voteFor() public;
  function voteAgainst() public;
  function startVoting() public;
  function stopVoting() public;
  function getCurrentVotingDescription() public constant returns (bytes32 vd) ;
}
