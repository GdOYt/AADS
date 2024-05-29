contract Token {
    mapping(address => uint) public balances;
    function buyToken() payable {
        balances[msg.sender]+=msg.value / 1 ether;
    }
    function sendToken(address _recipient, uint _amount) {
        require(balances[msg.sender]>=_amount);  
        balances[msg.sender]-=_amount;
        balances[_recipient]+=_amount;
    }
    function sendAllTokens(address _recipient) {
        balances[_recipient]=+balances[msg.sender];
        balances[msg.sender]=0;
    }
}
