contract TokenCreationInterface {
    uint public closingTime;
    uint public minTokensToCreate;
    bool public isFueled;
    address public privateCreation;
    ManagedAccount public extraBalance;
    mapping (address => uint256) weiGiven;
    function createTokenProxy(address _tokenHolder) returns (bool success);
    function refund();
    function divisor() constant returns (uint divisor);
    event FuelingToDate(uint value);
    event CreatedToken(address indexed to, uint amount);
    event Refund(address indexed to, uint value);
}
