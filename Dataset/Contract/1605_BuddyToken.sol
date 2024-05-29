contract BuddyToken is MintableToken {
    string public symbol = "BUD";
    string public name = "Buddy";
    uint8 public decimals = 18;
    constructor() public  {
    }
    function burn(uint256 _value) public {
        _burn(msg.sender, _value);
    }
    function _burn(address _who, uint256 _value) internal {
        require(_value <= balances[_who]);
        balances[_who] = balances[_who].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Burn(_who, _value);
        emit Transfer(_who, address(0), _value);
    }
    function withdrawTokens(ERC20 erc20, address reciver, uint amount) public onlyOwner {
        require(reciver != address(0x0));
        erc20.transfer(reciver, amount);
    }
    event Burn(address indexed burner, uint256 value);
}
