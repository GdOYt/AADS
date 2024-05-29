contract PresaleBREMP is Token {
    function PresaleBREMP(address _neurodao, uint _etherPrice)
        payable Token(_neurodao, _etherPrice) {}
    function withdraw() public {
        require(presaleOwner == msg.sender || owner == msg.sender);
        msg.sender.transfer(this.balance);
    }
    function killMe() public onlyOwner {
        presaleOwner.transfer(this.balance);
        selfdestruct(owner);
    }
}
