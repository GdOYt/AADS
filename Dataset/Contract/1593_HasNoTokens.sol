contract HasNoTokens is CanReclaimToken {
  function tokenFallback(address from_, uint256 value_, bytes data_) external {
    from_;
    value_;
    data_;
    revert();
  }
}
