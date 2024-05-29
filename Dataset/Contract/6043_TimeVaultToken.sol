contract TimeVaultToken is  owned, TimeVaultInterface, ERC20Token {
    function transferByOwner(address to, uint value, uint earliestReTransferTime) onlyOwner public returns (bool) {
        transfer(to, value);
        timevault[to] = earliestReTransferTime;
        return true;
    }
    function timeVault(address owner) public constant returns (uint earliestTransferTime) {
        return timevault[owner];
    }
    function getNow() public constant returns (uint blockchainTimeNow) {
        return now;
    }
}
