contract Cygnus is BurnableToken, Ownable {
    string public constant name = "Cygnus";
    string public constant symbol = "Cyg";
    uint public constant decimals = 18;
    uint256 public constant initialSupply = 16000000000 * (10 ** uint256(decimals));
    function Cygnus() {
        totalSupply = initialSupply;
        balances[msg.sender] = initialSupply; 
    }
}
