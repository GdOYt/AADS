contract TokenOwnable is Standard223Receiver, Ownable {
    modifier onlyTokenOwner() {
        require(tkn.sender == owner);
        _;
    }
}
