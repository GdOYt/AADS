contract ERC {
  function balanceOf (address) public view returns (uint256);
  function allowance (address, address) public view returns (uint256);
  function transfer (address, uint256) public returns (bool);
  function transferFrom (address, address, uint256) public returns (bool);
  function transferAndCall(address, uint256, bytes) public payable returns (bool);
  function approve (address, uint256) public returns (bool);
}
