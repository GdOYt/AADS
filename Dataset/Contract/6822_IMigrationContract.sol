contract IMigrationContract {
    function migrate(address _addr, uint256 _tokens, uint256 _totaltokens) public returns (bool success);
}
