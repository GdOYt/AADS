contract BitGooseCoin is PausableToken {
    string public constant name = "BitGooseCoin";
    string public constant symbol = "KBB";
    uint8 public constant decimals = 18;
    uint256 private constant TOKEN_UNIT = 10 ** uint256(decimals);
    uint256 public constant totalSupply = 2100000000 * TOKEN_UNIT;
    constructor() public {
        balances[owner] = totalSupply;
        emit Transfer(address(0), owner, balances[owner]);
    }
}
