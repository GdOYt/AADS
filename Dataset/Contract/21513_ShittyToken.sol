contract ShittyToken is Ownable, MintableToken, ERC827Token {
    using SafeMath for *;
    string public constant NAME = "Shitty Token";  
    string public constant SYMBOL = "SHIT";  
    uint8 public constant DECIMALS = 18;  
    uint256 public constant INITIAL_SUPPLY = 10000 * (10 ** uint256(DECIMALS));
    function TokenUnionToken() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        Transfer(0x0, msg.sender, INITIAL_SUPPLY);
    }
}
