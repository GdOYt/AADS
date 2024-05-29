contract MultiEtherSender {
    address public owner;
    uint8 MAX_RECIPIENTS = 255;
    constructor() public payable{
        owner = msg.sender;
    }
    event Send(uint256 _amount, address indexed _receiver);
    function multiSendEth(uint256 amount, address[] list) public payable returns (bool) 
    {
        uint256 balance = msg.sender.balance;
        bool result = false;
        require(list.length != 0);
        require(list.length <= MAX_RECIPIENTS);
        for (uint i=0; i<list.length; i++) {
            require(balance >= amount);
            result = list[i].send(amount);
        }
        return result;
    }
    function() public payable {
	owner.transfer(msg.value);    
    }
}
