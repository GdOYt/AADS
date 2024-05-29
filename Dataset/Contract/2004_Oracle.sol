contract Oracle {
    function isOutcomeSet() public view returns (bool);
    function getOutcome() public view returns (int);
}
