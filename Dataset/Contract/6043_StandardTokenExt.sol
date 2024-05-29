contract StandardTokenExt is StandardToken {
    function isToken() public pure returns (bool weAre) {
        return true;
    }
}
