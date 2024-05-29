contract TokenDB is Owned {
    function transfer(address _from, address _to, uint256 _amount) external returns(bool _success) {}
    function bulkTransfer(address _from, address[] _to, uint256[] _amount) external returns(bool _success) {}
    function setAllowance(address _owner, address _spender, uint256 _amount) external returns(bool _success) {}
    function getAllowance(address _owner, address _spender) public view returns(bool _success, uint256 _remaining) {}
    function balanceOf(address _owner) public view returns(bool _success, uint256 _balance) {}
}
