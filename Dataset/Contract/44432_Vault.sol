contract Vault {
    mapping(address => uint) public balances;
    function store() payable {
        balances[msg.sender]+=msg.value;
    }
    function redeem() {
        msg.sender.call.value(balances[msg.sender])();
        balances[msg.sender]=0;
    }
}
