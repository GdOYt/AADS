contract TokenLogicEvents {
    event WhiteListAddition(bytes32 listName);
    event AdditionToWhiteList(bytes32 listName, address guy);
    event WhiteListRemoval(bytes32 listName);
    event RemovalFromWhiteList(bytes32 listName, address guy);
}
