contract ECOToken is BurnableToken, HasNoEther {
    string public constant name = "ECO Token";
    string public constant symbol = "ECOT";
    uint8 public constant decimals = 18;
    uint256 constant INITIAL_SUPPLY = 583843 * (10 ** uint256(decimals));
    function ECOToken() public {
        totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        Transfer(address(0), msg.sender, totalSupply);
    }
    function transfer(address _to, uint256 _value) public returns (bool) {
        return super.transfer(_to, _value);
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }
    function multiTransfer(address[] recipients, uint256[] amounts) public {
        require(recipients.length == amounts.length);
        for (uint i = 0; i < recipients.length; i++) {
            transfer(recipients[i], amounts[i]);
        }
    }
    function mintToken(uint256 mintedAmount) public onlyOwner {
			totalSupply += mintedAmount;
			balances[owner] += mintedAmount;
			Transfer(address(0), owner, mintedAmount);
    }
}
