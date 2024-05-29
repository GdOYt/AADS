contract BBFarmEvents {
    event BallotCreatedWithID(uint ballotId);
    event BBFarmInit(bytes4 namespace);
    event Sponsorship(uint ballotId, uint value);
    event Vote(uint indexed ballotId, bytes32 vote, address voter, bytes extra);
    event BallotOnForeignNetwork(bytes32 networkId, uint ballotId);   
}
