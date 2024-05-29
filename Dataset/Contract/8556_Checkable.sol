contract Checkable {
    address private serviceAccount;
    bool private triggered = false;
    event Triggered(uint balance);
    event Checked(bool isAccident);
    function Checkable() public {
        serviceAccount = msg.sender;
    }
    function changeServiceAccount(address _account) onlyService public {
        assert(_account != 0);
        serviceAccount = _account;
    }
    function isServiceAccount() view public returns (bool) {
        return msg.sender == serviceAccount;
    }
    function check() onlyService notTriggered payable public {
        if (internalCheck()) {
            emit Triggered(this.balance);
            triggered = true;
            internalAction();
        }
    }
    function internalCheck() internal returns (bool);
    function internalAction() internal;
    modifier onlyService {
        require(msg.sender == serviceAccount);
        _;
    }
    modifier notTriggered() {
        require(!triggered);
        _;
    }
}
