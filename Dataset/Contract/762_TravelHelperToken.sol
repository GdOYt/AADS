contract TravelHelperToken {
    function transfer (address, uint) public pure { }
    function burnTokensForSale() public returns (bool);
    function saleTransfer(address _to, uint256 _value) public returns (bool) {}
    function finalize() public pure { }
}
