contract P4PPool {
    address public owner;
    PlayToken public playToken;
    uint8 public currentState = 0;
    uint8 public constant STATE_NOT_STARTED = 0;
    uint8 public constant STATE_DONATION_ROUND_1 = 1;
    uint8 public constant STATE_PLAYING = 2;
    uint8 public constant STATE_DONATION_ROUND_2 = 3;
    uint8 public constant STATE_PAYOUT = 4;
    uint256 public tokenPerEth;  
    mapping(address => uint256) round1Donations;
    mapping(address => uint256) round2Donations;
    uint256 public totalPhase1Donations = 0;
    uint256 public totalPhase2Donations = 0;
    uint32 public donationUnlockTs = uint32(now);  
    uint8 public constant ownerTokenSharePct = 20;
    address public donationReceiver;
    bool public donationReceiverLocked = false;
    event StateChanged(uint8 newState);
    event DonatedEthPayout(address receiver, uint256 amount);
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    modifier onlyDuringDonationRounds() {
        require(currentState == STATE_DONATION_ROUND_1 || currentState == STATE_DONATION_ROUND_2);
        _;
    }
    modifier onlyIfPayoutUnlocked() {
        require(currentState == STATE_PAYOUT);
        require(uint32(now) >= donationUnlockTs);
        _;
    }
    function P4PPool(address _tokenAddr) {
        owner = msg.sender;
        playToken = PlayToken(_tokenAddr);
    }
    function () payable onlyDuringDonationRounds {
        donateForImpl(msg.sender);
    }
    function donateFor(address _donor) payable onlyDuringDonationRounds {
        donateForImpl(_donor);
    }
    function startNextPhase() onlyOwner {
        require(currentState <= STATE_PAYOUT);
        currentState++;
        if(currentState == STATE_PAYOUT) {
            tokenPerEth = calcTokenPerEth();
        }
        StateChanged(currentState);
    }
    function setDonationUnlockTs(uint32 _newTs) onlyOwner {
        require(_newTs > donationUnlockTs);
        donationUnlockTs = _newTs;
    }
    function setDonationReceiver(address _receiver) onlyOwner {
        require(! donationReceiverLocked);
        donationReceiver = _receiver;
    }
    function lockDonationReceiver() onlyOwner {
        require(donationReceiver != 0);
        donationReceiverLocked = true;
    }
    function payoutDonations() onlyOwner onlyIfPayoutUnlocked {
        require(donationReceiver != 0);
        var amount = this.balance;
        require(donationReceiver.send(amount));
        DonatedEthPayout(donationReceiver, amount);
    }
    function destroy() onlyOwner {
        require(currentState == STATE_PAYOUT);
        require(now > 1519862400);
        selfdestruct(owner);
    }
    function withdrawTokenShare() {
        require(tokenPerEth > 0);  
        require(playToken.transfer(msg.sender, calcTokenShareOf(msg.sender)));
        round1Donations[msg.sender] = 0;
        round2Donations[msg.sender] = 0;
    }
    function calcTokenShareOf(address _addr) constant internal returns(uint256) {
        if(_addr == owner) {
            var virtualEthBalance = (((totalPhase1Donations*2 + totalPhase2Donations) * 100) / (100 - ownerTokenSharePct) + 1);
            return ((tokenPerEth * virtualEthBalance) * ownerTokenSharePct) / (100 * 1E18);
        } else {
            return (tokenPerEth * (round1Donations[_addr]*2 + round2Donations[_addr])) / 1E18;
        }
    }
    function calcTokenPerEth() constant internal returns(uint256) {
        var tokenBalance = playToken.balanceOf(this);
        var virtualEthBalance = (((totalPhase1Donations*2 + totalPhase2Donations) * 100) / (100 - ownerTokenSharePct) + 1);
        return tokenBalance * 1E18 / (virtualEthBalance);
    }
    function donateForImpl(address _donor) internal onlyDuringDonationRounds {
        if(currentState == STATE_DONATION_ROUND_1) {
            round1Donations[_donor] += msg.value;
            totalPhase1Donations += msg.value;
        } else if(currentState == STATE_DONATION_ROUND_2) {
            round2Donations[_donor] += msg.value;
            totalPhase2Donations += msg.value;
        }
    }
}
