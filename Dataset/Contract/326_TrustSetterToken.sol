contract TrustSetterToken is StandardToken, HasNoEther {
    string public constant name = "TrustSetterToken";
    string public constant symbol = "TS";
    uint8 public constant decimals = 18;
    uint256 constant INITIAL_SUPPLY = 582000000 * (10 ** uint256(decimals));
    uint256 constant FREEZE_END = 1549929600;
    constructor() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        emit Transfer(address(0), msg.sender, totalSupply());
    }
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(msg.sender == owner || now >= FREEZE_END);
        return super.transfer(_to, _value);
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(msg.sender == owner || now >= FREEZE_END);
        return super.transferFrom(_from, _to, _value);
    }
    function multiTransfer(address[] recipients, uint256[] amounts) public {
        require(recipients.length == amounts.length);
        for (uint i = 0; i < recipients.length; i++) {
            transfer(recipients[i], amounts[i]);
        }
    }
}
