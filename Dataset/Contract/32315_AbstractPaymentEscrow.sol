contract AbstractPaymentEscrow is Ownable {
    address public wallet;
    mapping (uint => uint) public deposits;
    event Payment(address indexed _customer, uint indexed _projectId, uint value);
    event Withdraw(address indexed _wallet, uint value);
    function withdrawFunds() public;
    function changeWallet(address _wallet)
        public
        onlyOwner()
    {
        wallet = _wallet;
    }
    function getDeposit(uint _projectId)
        public
        constant
        returns (uint)
    {
        return deposits[_projectId];
    }
}
