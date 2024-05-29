contract BrickToken is MintableToken {
    string public constant name = "The Brick"; 
    string public constant symbol = "BRK";
    uint8 public constant decimals = 18;
    function getTotalSupply() view public returns (uint256) {
        return totalSupply;
    }
    function transfer(address _to, uint256 _value) public returns (bool) {
        super.transfer(_to, _value);
    }
}
