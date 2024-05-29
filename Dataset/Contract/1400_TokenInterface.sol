contract TokenInterface is ERC20 {
    function deposit() public payable;
    function withdraw(uint) public;
}
