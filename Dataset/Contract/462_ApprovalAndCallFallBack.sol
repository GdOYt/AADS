contract ApprovalAndCallFallBack {
  function receiveApproval(address _owner, uint256 _amount, address _token, bytes _data) public returns (bool);
}
