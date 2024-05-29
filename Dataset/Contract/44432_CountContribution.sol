contract CountContribution{
    mapping(address => uint) public contribution;
    uint public totalContributions;
    address owner=msg.sender;
    function CountContribution() public {
        recordContribution(owner, 1 ether);
    }
    function contribute() public payable {
        recordContribution(msg.sender, msg.value);
    }
    function recordContribution(address _user, uint _amount) {
        contribution[_user]+=_amount;
        totalContributions+=_amount;
    }
}
