contract Kubic is BurnableToken, Ownable {
    string public constant name = "Kubic"; 
    string public constant symbol = "KIC"; 
    uint public constant decimals = 8;  
    uint256 public constant initialSupply = 200000000 * (10 ** uint256(decimals)); 
    function Kubic() {
        totalSupply = initialSupply;
        balances[msg.sender] = initialSupply; 
    }
}
