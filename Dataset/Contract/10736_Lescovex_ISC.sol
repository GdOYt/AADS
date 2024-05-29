contract Lescovex_ISC is LescovexERC20 {
    uint256 public contractBalance = 0;
    event LogDeposit(address sender, uint amount);
    event LogWithdrawal(address receiver, uint amount);
    address contractAddr = this;
    constructor (
        uint256 initialSupply,
        string contractName,
        string tokenSymbol,
        uint256 contractHoldTime,
        address contractOwner
        ) public {
        totalSupply = initialSupply;   
        name = contractName;              
        symbol = tokenSymbol;          
        holdTime = contractHoldTime;
        balances[contractOwner] = totalSupply;
    }
    function deposit() external payable onlyOwner returns(bool success) {
        contractBalance = contractAddr.balance;
        emit LogDeposit(msg.sender, msg.value);
        return true;
    }
    function withdrawReward() external {
        uint256 ethAmount = (holdedOf(msg.sender) * contractBalance) / totalSupply;
        require(ethAmount > 0);
        emit LogWithdrawal(msg.sender, ethAmount);
        delete holded[msg.sender];
        hold(msg.sender,balances[msg.sender]);
        msg.sender.transfer(ethAmount);
    }
    function withdraw(uint256 value) external onlyOwner {
        msg.sender.transfer(value);
        emit LogWithdrawal(msg.sender, value);
    }
}
