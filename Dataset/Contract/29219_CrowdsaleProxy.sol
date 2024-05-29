contract CrowdsaleProxy is ICrowdsaleProxy {
    address public owner;
    ICrowdsale public target;
    function CrowdsaleProxy(address _owner, address _target) public {
        target = ICrowdsale(_target);
        owner = _owner;
    }
    function () public payable {
        target.contributeFor.value(msg.value)(msg.sender);
    }
    function contribute() public payable returns (uint) {
        target.contributeFor.value(msg.value)(msg.sender);
    }
    function contributeFor(address _beneficiary) public payable returns (uint) {
        target.contributeFor.value(msg.value)(_beneficiary);
    }
}
