contract Token is CappedToken, BurnableToken, Withdrawable {
    function Token() CappedToken(70000000 * 1 ether) StandardToken("IAM Aero", "IAM", 18) public {
    }
    function tokenFallback(address _from, uint256 _value, bytes _data) external {
        require(false);
    }
}
