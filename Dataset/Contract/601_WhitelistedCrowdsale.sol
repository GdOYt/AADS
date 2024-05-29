contract WhitelistedCrowdsale is StandardCrowdsale, Ownable {
    mapping(address=>bool) public registered;
    event RegistrationStatusChanged(address target, bool isRegistered);
    function changeRegistrationStatus(address target, bool isRegistered) public onlyOwner {
        registered[target] = isRegistered;
        RegistrationStatusChanged(target, isRegistered);
    }
    function changeRegistrationStatuses(address[] targets, bool isRegistered) public onlyOwner {
        for (uint i = 0; i < targets.length; i++) {
            changeRegistrationStatus(targets[i], isRegistered);
        }
    }
    function validPurchase() internal returns (bool) {
        return super.validPurchase() && registered[msg.sender];
    }
}
