contract ERC223Receiving {
    function tokenFallback(address from, uint256 value, bytes data) external;
}
