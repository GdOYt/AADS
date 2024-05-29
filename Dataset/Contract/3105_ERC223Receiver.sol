contract ERC223Receiver {
    constructor() internal {}
    function tokenFallback(address _from, uint _value, bytes _data) public;
}
