contract ZethrInterface {
    function buyAndTransfer(address _referredBy, address target, bytes _data, uint8 divChoice) public payable;
    function balanceOf(address _owner) view public returns(uint);
}
