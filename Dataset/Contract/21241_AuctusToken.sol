contract AuctusToken {
	function transfer(address to, uint256 value) public returns (bool);
	function transfer(address to, uint256 value, bytes data) public returns (bool);
	function burn(uint256 value) public returns (bool);
	function setTokenSaleFinished() public;
}
