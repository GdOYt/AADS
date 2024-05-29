contract Storage {
uint scoringThreshold ; 
struct Proposal 
  {
    string ipfsAddress ; 
    uint timestamp ; 
    uint totalAffirmativeVotes ; 
    uint totalNegativeVotes ; 
    uint totalVoters ; 
    address[] votersAcct ; 
    mapping (address => uint) votes ; 
  }
mapping (bytes32 => Proposal) public proposals ; 
uint256 totalProposals ; 
bytes32[] rootHashesProposals ; 
mapping (bytes32 => string) public ipfsAddresses ; 
bytes32[] ipfsAddressesAcct ;
}
