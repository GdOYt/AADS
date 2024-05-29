contract ITime is Controlled, ITyped {
    function getTimestamp() external view returns (uint256);
}
