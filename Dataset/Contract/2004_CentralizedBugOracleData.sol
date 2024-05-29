contract CentralizedBugOracleData {
  event OwnerReplacement(address indexed newOwner);
  event OutcomeAssignment(int outcome);
  address public owner;
  bytes public ipfsHash;
  bool public isSet;
  int public outcome;
  address public maker;
  address public taker;
  modifier isOwner () {
      require(msg.sender == owner);
      _;
  }
}
