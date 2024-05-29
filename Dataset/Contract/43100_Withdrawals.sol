contract Withdrawals is Claimable {
    address public withdrawCreator;
    event AmountWithdrawEvent(
    address _destination, 
    uint _amount, 
    address _tokenAddress 
    );
    function() payable public {
    }
    function setWithdrawCreator(address _withdrawCreator) public onlyOwner {
        withdrawCreator = _withdrawCreator;
    }
    function withdraw(address[] _destinations, uint[] _amounts, address[] _tokenAddresses) public onlyOwnerOrWithdrawCreator {
        require(_destinations.length == _amounts.length && _amounts.length == _tokenAddresses.length);
        for (uint i = 0; i < _destinations.length; i++) {
            address tokenAddress = _tokenAddresses[i];
            uint amount = _amounts[i];
            address destination = _destinations[i];
            if (tokenAddress == address(0)) {
                if (this.balance < amount) {
                    continue;
                }
                if (!destination.call.gas(70000).value(amount)()) {
                    continue;
                }
            }else {
                if (ERC20(tokenAddress).balanceOf(this) < amount) {
                    continue;
                }
                ERC20(tokenAddress).transfer(destination, amount);
            }
            emit AmountWithdrawEvent(destination, amount, tokenAddress);                
        }
    }
    modifier onlyOwnerOrWithdrawCreator() {
        require(msg.sender == withdrawCreator || msg.sender == owner);
        _;
    }
}
