contract Stoppable is Ownable {
    bool public stopped = false;
    bool public withdrawalEnabled = false;
    modifier whenStopped() {
        require(stopped);
        _;
    }
    modifier whenNotStopped() {
        require(!stopped);
        _;
    }
    modifier whenWithdrawalEnabled() {
        require(withdrawalEnabled);
        _;
    }
    modifier whenWithdrawalDisabled() {
        require(!withdrawalEnabled);
        _;
    }
    function stop() public onlyOwner whenNotStopped {
        stopped = true;
        emit Stopped(owner);
    }
    function restart() public onlyOwner whenStopped {
        stopped = false;
        withdrawalEnabled = false;
        emit Restarted(owner);
    }
    function enableWithdrawal() public onlyOwner whenStopped whenWithdrawalDisabled {
        withdrawalEnabled = true;
        emit WithdrawalEnabled(owner);
    }
    function disableWithdrawal() public onlyOwner whenWithdrawalEnabled {
        withdrawalEnabled = false;
        emit WithdrawalDisabled(owner);
    }
    event Stopped(address owner);
    event Restarted(address owner);
    event WithdrawalEnabled(address owner);
    event WithdrawalDisabled(address owner);
}
