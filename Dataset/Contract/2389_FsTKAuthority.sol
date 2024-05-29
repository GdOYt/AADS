contract FsTKAuthority {
  function isAuthorized(address sender, address _contract, bytes data) public view returns (bool);
  function isApproved(bytes32 hash, uint256 approveTime, bytes approveToken) public view returns (bool);
  function validate() public pure returns (bytes4);
}
