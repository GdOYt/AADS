contract TokenState is State {
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    constructor(address _owner, address _associatedContract)
        State(_owner, _associatedContract)
        public
    {}
    function setAllowance(address tokenOwner, address spender, uint value)
        external
        onlyAssociatedContract
    {
        allowance[tokenOwner][spender] = value;
    }
    function setBalanceOf(address account, uint value)
        external
        onlyAssociatedContract
    {
        balanceOf[account] = value;
    }
}
