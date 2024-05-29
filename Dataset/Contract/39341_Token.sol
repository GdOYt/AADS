contract Token {
    function transfer(address, uint) returns(bool);
    function balanceOf(address) constant returns (uint);
}
