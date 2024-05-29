contract EmergencyWithdrawalModule is usingInvestorsModule {
    uint constant EMERGENCY_WITHDRAWAL_RATIO = 80;  
    uint constant EMERGENCY_TIMEOUT = 3 days;
    struct WithdrawalProposal {
        address toAddress;
        uint atTime;
    }
    WithdrawalProposal public proposedWithdrawal;
    event LOG_EmergencyWithdrawalProposed();
    event LOG_EmergencyWithdrawalFailed(address indexed withdrawalAddress);
    event LOG_EmergencyWithdrawalSucceeded(address indexed withdrawalAddress, uint amountWithdrawn);
    event LOG_EmergencyWithdrawalVote(address indexed investor, bool vote);
    modifier onlyAfterProposed {
        assert(proposedWithdrawal.toAddress != 0);
        _;
    }
    modifier onlyIfEmergencyTimeOutHasPassed {
        assert(proposedWithdrawal.atTime + EMERGENCY_TIMEOUT <= now);
        _;
    }
    function voteEmergencyWithdrawal(bool vote)
        onlyInvestors
        onlyAfterProposed
        onlyIfStopped {
        investors[investorIDs[msg.sender]].votedForEmergencyWithdrawal = vote;
        LOG_EmergencyWithdrawalVote(msg.sender, vote);
    }
    function proposeEmergencyWithdrawal(address withdrawalAddress)
        onlyIfStopped
        onlyOwner {
        for (uint i = 1; i <= numInvestors; i++) {
            delete investors[i].votedForEmergencyWithdrawal;
        }
        proposedWithdrawal = WithdrawalProposal(withdrawalAddress, now);
        LOG_EmergencyWithdrawalProposed();
    }
    function executeEmergencyWithdrawal()
        onlyOwner
        onlyAfterProposed
        onlyIfStopped
        onlyIfEmergencyTimeOutHasPassed {
        uint numOfVotesInFavour;
        uint amountToWithdraw = this.balance;
        for (uint i = 1; i <= numInvestors; i++) {
            if (investors[i].votedForEmergencyWithdrawal == true) {
                numOfVotesInFavour++;
                delete investors[i].votedForEmergencyWithdrawal;
            }
        }
        if (numOfVotesInFavour >= EMERGENCY_WITHDRAWAL_RATIO * numInvestors / 100) {
            if (!proposedWithdrawal.toAddress.send(amountToWithdraw)) {
                LOG_EmergencyWithdrawalFailed(proposedWithdrawal.toAddress);
            }
            else {
                LOG_EmergencyWithdrawalSucceeded(proposedWithdrawal.toAddress, amountToWithdraw);
            }
        }
        else {
            revert();
        }
    }
    function forceDivestOfOneInvestor(address currentInvestor)
        onlyOwner
        onlyIfStopped {
        divest(currentInvestor);
        delete proposedWithdrawal;
    }
}
