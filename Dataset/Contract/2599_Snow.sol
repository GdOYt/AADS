contract Snow {
    function buy(address) public payable returns(uint256);
    function withdraw() public;
    function redistribution() external payable;
    function myTokens() public view returns(uint256);
    function myDividends(bool) public view returns(uint256);
}
