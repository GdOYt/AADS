contract ManagedAccountInterface {
    address public owner;
    bool public payOwnerOnly;
    uint public accumulatedInput;
    function payOut(address _recipient, uint _amount) returns (bool);
    event PayOut(address indexed _recipient, uint _amount);
}
