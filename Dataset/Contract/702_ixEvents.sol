contract ixEvents {
    event PaymentMade(uint[2] valAndRemainder);
    event AddedBBFarm(uint8 bbFarmId);
    event SetBackend(bytes32 setWhat, address newSC);
    event DeprecatedBBFarm(uint8 bbFarmId);
    event CommunityBallot(bytes32 democHash, uint256 ballotId);
    event ManuallyAddedBallot(bytes32 democHash, uint256 ballotId, uint256 packed);
    event BallotCreatedWithID(uint ballotId);
    event BBFarmInit(bytes4 namespace);
}
