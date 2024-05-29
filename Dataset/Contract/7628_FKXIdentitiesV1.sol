contract FKXIdentitiesV1 is Storage, Roles {
using SafeMath for uint256;
event newProposalLogged(address indexed initiator, bytes32 rootHash, string ipfsAddress ) ; 
event newVoteLogged(address indexed voter, bool vote) ;
event newIpfsAddressAdded(bytes32 rootHash, string ipfsAddress ) ; 
constructor() public 
{
  qtyInitiators = 0 ; 
  qtyValidators = 0 ; 
  scoringThreshold = 10 ;
}
function setScoringThreshold(uint _scoreMax) public onlySuperAdmin
{
  scoringThreshold = _scoreMax ; 
}
function propose(bytes32 _rootHash, string _ipfsAddress) public onlyInitiators
{
  require(proposals[_rootHash].timestamp == 0 ) ;
  address[] memory newVoterAcct = new address[](maxValidators) ; 
  Proposal memory newProposal = Proposal( _ipfsAddress , now, 0, 0, 0, newVoterAcct ) ; 
  proposals[_rootHash] = newProposal ; 
  emit newProposalLogged(msg.sender, _rootHash, _ipfsAddress ) ; 
  rootHashesProposals.push(_rootHash) ; 
  totalProposals++ ; 
}
function getIpfsAddress(bytes32 _rootHash) constant public returns (string _ipfsAddress)
{
  return ipfsAddresses[_rootHash] ; 
}
function getProposedIpfs(bytes32 _rootHash) constant public returns (string _ipfsAddress)
{
  return proposals[_rootHash].ipfsAddress ; 
}
function howManyVoters(bytes32 _rootHash) constant public returns (uint)
{
  return proposals[_rootHash].totalVoters ; 
}
function vote(bytes32 _rootHash, bool _vote) public onlyValidators
{
  require(proposals[_rootHash].timestamp > 0) ;
  require(proposals[_rootHash].votes[msg.sender]==0) ; 
  proposals[_rootHash].votersAcct.push(msg.sender) ; 
  if (_vote ) 
    { 
      proposals[_rootHash].votes[msg.sender] = 1 ;  
      proposals[_rootHash].totalAffirmativeVotes++ ; 
    } 
       else 
        { proposals[_rootHash].votes[msg.sender] = 2 ;  
          proposals[_rootHash].totalNegativeVotes++ ; 
        } 
  emit newVoteLogged(msg.sender, _vote) ;
  proposals[_rootHash].totalVoters++ ; 
  if ( isConsensusObtained(proposals[_rootHash].totalAffirmativeVotes) )
  {
    bytes memory tempEmptyString = bytes(ipfsAddresses[_rootHash]) ; 
    if ( tempEmptyString.length == 0 ) 
      { 
        ipfsAddresses[_rootHash] = proposals[_rootHash].ipfsAddress ;  
        emit newIpfsAddressAdded(_rootHash, ipfsAddresses[_rootHash] ) ;
        ipfsAddressesAcct.push(_rootHash) ; 
      } 
  }
} 
function getTotalQtyIpfsAddresses() constant public returns (uint)
{ 
  return ipfsAddressesAcct.length ; 
}
function getOneByOneRootHash(uint _index) constant public returns (bytes32 _rootHash )
{
  require( _index <= (getTotalQtyIpfsAddresses()-1) ) ; 
  return ipfsAddressesAcct[_index] ; 
}
function isConsensusObtained(uint _totalAffirmativeVotes) constant public returns (bool)
{
 require (qtyValidators > 0) ;  
 uint dTotalVotes = _totalAffirmativeVotes * 10000 ; 
 return (dTotalVotes / qtyValidators > 5000 ) ;
}
function getProposals(uint _timestampFrom) constant public returns (bytes32 _rootHash)
{
   uint max = rootHashesProposals.length ; 
   for(uint i = 0 ; i < max ; i++ ) 
    {
      if (proposals[rootHashesProposals[i]].timestamp > _timestampFrom)
         return rootHashesProposals[i] ; 
    }
}
function getTimestampProposal(bytes32 _rootHash) constant public returns (uint _timeStamp) 
{
  return proposals[_rootHash].timestamp ; 
}
function getQtyValidators() constant public returns (uint)
{
  return qtyValidators ; 
}
function getValidatorAddress(int _t) constant public returns (address _validatorAddr)
{
   int x = -1 ; 
   uint size = validatorsAcct.length ; 
   for ( uint i = 0 ; i < size ; i++ )
   {
      if ( validators[validatorsAcct[i]] ) x++ ; 
      if ( x == _t ) return (validatorsAcct[i]) ;  
   }
}
function getStatusForRootHash(bytes32 _rootHash) constant public returns (bool)
{
 bytes memory tempEmptyStringTest = bytes(ipfsAddresses[_rootHash]);  
 if (tempEmptyStringTest.length == 0) {
    return false ; 
} else {
    return true ; 
}
} 
}  
