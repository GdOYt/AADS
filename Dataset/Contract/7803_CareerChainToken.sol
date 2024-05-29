contract CareerChainToken is CappedToken(145249999000000000000000000), BurnableToken  {
    string public name = "CareerChain Token";
    string public symbol = "CCH";
    uint8 public decimals = 18;
    function burn(uint256 _value) public onlyOwner {
      _burn(msg.sender, _value);
    }
}
