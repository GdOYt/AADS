contract TradersWallet {
    address public owner;
    string public version;
    etherDelta private ethDelta;
    address public ethDeltaDepositAddress;
    function TradersWallet() {
        owner = msg.sender;
        version = "ALPHA 0.1";
        ethDeltaDepositAddress = 0x8d12A197cB00D4747a1fe03395095ce2A5CC6819;
        ethDelta = etherDelta(ethDeltaDepositAddress);
    }
    function() payable {
    }
    function tokenBalance(address tokenAddress) constant returns (uint) {
        Token token = Token(tokenAddress);
        return token.balanceOf(this);
    }
    function transferFromToken(address tokenAddress, address sendTo, address sendFrom, uint256 amount) external {
        require(msg.sender==owner);
        Token token = Token(tokenAddress);
        token.transferFrom(sendTo, sendFrom, amount);
    }
    function changeOwner(address newOwner) external {
        require(msg.sender==owner);
        owner = newOwner;
    }
    function sendEther(address toAddress, uint amount) external {
        require(msg.sender==owner);
        toAddress.transfer(amount);
    }
    function sendToken(address tokenAddress, address sendTo, uint256 amount) external {
        require(msg.sender==owner);
        Token token = Token(tokenAddress);
        token.transfer(sendTo, amount);
    }
    function execute(address _to, uint _value, bytes _data) external returns (bytes32 _r) {
        require(msg.sender==owner);
        require(_to.call.value(_value)(_data));
        return 0;
    }
    function EtherDeltaTokenBalance(address tokenAddress) constant returns (uint) {
        return ethDelta.balanceOf(tokenAddress, this);
    }
    function EtherDeltaWithdrawToken(address tokenAddress, uint amount) payable external {
        require(msg.sender==owner);
        ethDelta.withdrawToken(tokenAddress, amount);
    }
    function changeEtherDeltaDeposit(address newEthDelta) external {
        require(msg.sender==owner);
        ethDeltaDepositAddress = newEthDelta;
        ethDelta = etherDelta(newEthDelta);
    }
    function EtherDeltaDepositToken(address tokenAddress, uint amount) payable external {
        require(msg.sender==owner);
        ethDelta.depositToken(tokenAddress, amount);
    }
    function EtherDeltaApproveToken(address tokenAddress, uint amount) payable external {
        require(msg.sender==owner);
        Token token = Token(tokenAddress);
        token.approve(ethDeltaDepositAddress, amount);
    }
    function EtherDeltaDeposit(uint amount) payable external {
        require(msg.sender==owner);
        ethDelta.deposit.value(amount)();
    }
    function EtherDeltaWithdraw(uint amount) external {
        require(msg.sender==owner);
        ethDelta.withdraw(amount);
    }
    function kill() {
        require(msg.sender==owner);
        suicide(msg.sender);
    }
}
