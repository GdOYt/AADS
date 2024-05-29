contract PeopleWaveToken is StandardToken {
    string public constant name = "PeopleWave Token";
    string public constant symbol = "PPL";
    uint8 public constant decimals = 18;
    uint public constant initialSupply = 1200000000000000000000000000;
    constructor() public {
        totalSupply_ = initialSupply;
        balances[msg.sender] = initialSupply;
    }
}
