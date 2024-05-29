contract Authority {
    function isValidAuthority(address authorityAddress, uint blockNumber) public view returns (bool);
}
