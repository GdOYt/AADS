contract Court is SafeDecimalMath, Owned {
    Havven public havven;
    Nomin public nomin;
    uint public minStandingBalance = 100 * UNIT;
    uint public votingPeriod = 1 weeks;
    uint constant MIN_VOTING_PERIOD = 3 days;
    uint constant MAX_VOTING_PERIOD = 4 weeks;
    uint public confirmationPeriod = 1 weeks;
    uint constant MIN_CONFIRMATION_PERIOD = 1 days;
    uint constant MAX_CONFIRMATION_PERIOD = 2 weeks;
    uint public requiredParticipation = 3 * UNIT / 10;
    uint constant MIN_REQUIRED_PARTICIPATION = UNIT / 10;
    uint public requiredMajority = (2 * UNIT) / 3;
    uint constant MIN_REQUIRED_MAJORITY = UNIT / 2;
    uint nextMotionID = 1;
    mapping(uint => address) public motionTarget;
    mapping(address => uint) public targetMotionID;
    mapping(uint => uint) public motionStartTime;
    mapping(uint => uint) public votesFor;
    mapping(uint => uint) public votesAgainst;
    mapping(address => mapping(uint => uint)) voteWeight;
    enum Vote {Abstention, Yea, Nay}
    mapping(address => mapping(uint => Vote)) public vote;
    constructor(Havven _havven, Nomin _nomin, address _owner)
        Owned(_owner)
        public
    {
        havven = _havven;
        nomin = _nomin;
    }
    function setMinStandingBalance(uint balance)
        external
        onlyOwner
    {
        minStandingBalance = balance;
    }
    function setVotingPeriod(uint duration)
        external
        onlyOwner
    {
        require(MIN_VOTING_PERIOD <= duration &&
                duration <= MAX_VOTING_PERIOD);
        require(duration <= havven.feePeriodDuration());
        votingPeriod = duration;
    }
    function setConfirmationPeriod(uint duration)
        external
        onlyOwner
    {
        require(MIN_CONFIRMATION_PERIOD <= duration &&
                duration <= MAX_CONFIRMATION_PERIOD);
        confirmationPeriod = duration;
    }
    function setRequiredParticipation(uint fraction)
        external
        onlyOwner
    {
        require(MIN_REQUIRED_PARTICIPATION <= fraction);
        requiredParticipation = fraction;
    }
    function setRequiredMajority(uint fraction)
        external
        onlyOwner
    {
        require(MIN_REQUIRED_MAJORITY <= fraction);
        requiredMajority = fraction;
    }
    function motionVoting(uint motionID)
        public
        view
        returns (bool)
    {
        return motionStartTime[motionID] < now && now < motionStartTime[motionID] + votingPeriod;
    }
    function motionConfirming(uint motionID)
        public
        view
        returns (bool)
    {
        uint startTime = motionStartTime[motionID];
        return startTime + votingPeriod <= now &&
               now < startTime + votingPeriod + confirmationPeriod;
    }
    function motionWaiting(uint motionID)
        public
        view
        returns (bool)
    {
        return motionStartTime[motionID] + votingPeriod + confirmationPeriod <= now;
    }
    function motionPasses(uint motionID)
        public
        view
        returns (bool)
    {
        uint yeas = votesFor[motionID];
        uint nays = votesAgainst[motionID];
        uint totalVotes = safeAdd(yeas, nays);
        if (totalVotes == 0) {
            return false;
        }
        uint participation = safeDiv_dec(totalVotes, havven.totalIssuanceLastAverageBalance());
        uint fractionInFavour = safeDiv_dec(yeas, totalVotes);
        return participation > requiredParticipation &&
               fractionInFavour > requiredMajority;
    }
    function hasVoted(address account, uint motionID)
        public
        view
        returns (bool)
    {
        return vote[account][motionID] != Vote.Abstention;
    }
    function beginMotion(address target)
        external
        returns (uint)
    {
        require((havven.issuanceLastAverageBalance(msg.sender) >= minStandingBalance) ||
                msg.sender == owner);
        require(votingPeriod <= havven.feePeriodDuration());
        require(targetMotionID[target] == 0);
        require(!nomin.frozen(target));
        havven.rolloverFeePeriodIfElapsed();
        uint motionID = nextMotionID++;
        motionTarget[motionID] = target;
        targetMotionID[target] = motionID;
        uint startTime = havven.feePeriodStartTime() + havven.feePeriodDuration();
        motionStartTime[motionID] = startTime;
        emit MotionBegun(msg.sender, target, motionID, startTime);
        return motionID;
    }
    function setupVote(uint motionID)
        internal
        returns (uint)
    {
        require(motionVoting(motionID));
        require(!hasVoted(msg.sender, motionID));
        require(msg.sender != motionTarget[motionID]);
        uint weight = havven.recomputeLastAverageBalance(msg.sender);
        require(weight > 0);
        voteWeight[msg.sender][motionID] = weight;
        return weight;
    }
    function voteFor(uint motionID)
        external
    {
        uint weight = setupVote(motionID);
        vote[msg.sender][motionID] = Vote.Yea;
        votesFor[motionID] = safeAdd(votesFor[motionID], weight);
        emit VotedFor(msg.sender, motionID, weight);
    }
    function voteAgainst(uint motionID)
        external
    {
        uint weight = setupVote(motionID);
        vote[msg.sender][motionID] = Vote.Nay;
        votesAgainst[motionID] = safeAdd(votesAgainst[motionID], weight);
        emit VotedAgainst(msg.sender, motionID, weight);
    }
    function cancelVote(uint motionID)
        external
    {
        require(!motionConfirming(motionID));
        Vote senderVote = vote[msg.sender][motionID];
        require(senderVote != Vote.Abstention);
        if (motionVoting(motionID)) {
            if (senderVote == Vote.Yea) {
                votesFor[motionID] = safeSub(votesFor[motionID], voteWeight[msg.sender][motionID]);
            } else {
                votesAgainst[motionID] = safeSub(votesAgainst[motionID], voteWeight[msg.sender][motionID]);
            }
            emit VoteCancelled(msg.sender, motionID);
        }
        delete voteWeight[msg.sender][motionID];
        delete vote[msg.sender][motionID];
    }
    function _closeMotion(uint motionID)
        internal
    {
        delete targetMotionID[motionTarget[motionID]];
        delete motionTarget[motionID];
        delete motionStartTime[motionID];
        delete votesFor[motionID];
        delete votesAgainst[motionID];
        emit MotionClosed(motionID);
    }
    function closeMotion(uint motionID)
        external
    {
        require((motionConfirming(motionID) && !motionPasses(motionID)) || motionWaiting(motionID));
        _closeMotion(motionID);
    }
    function approveMotion(uint motionID)
        external
        onlyOwner
    {
        require(motionConfirming(motionID) && motionPasses(motionID));
        address target = motionTarget[motionID];
        nomin.freezeAndConfiscate(target);
        _closeMotion(motionID);
        emit MotionApproved(motionID);
    }
    function vetoMotion(uint motionID)
        external
        onlyOwner
    {
        require(!motionWaiting(motionID));
        _closeMotion(motionID);
        emit MotionVetoed(motionID);
    }
    event MotionBegun(address indexed initiator, address indexed target, uint indexed motionID, uint startTime);
    event VotedFor(address indexed voter, uint indexed motionID, uint weight);
    event VotedAgainst(address indexed voter, uint indexed motionID, uint weight);
    event VoteCancelled(address indexed voter, uint indexed motionID);
    event MotionClosed(uint indexed motionID);
    event MotionVetoed(uint indexed motionID);
    event MotionApproved(uint indexed motionID);
}
