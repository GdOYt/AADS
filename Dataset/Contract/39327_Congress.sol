contract Congress is Object, Recipient {
    uint256 public minimumQuorum;
    uint256 public debatingPeriodInMinutes;
    int256 public majorityMargin;
    Proposal[] public proposals;
    function numProposals() constant returns (uint256)
    { return proposals.length; }
    Member[] public members;
    mapping(address => uint256) public memberId;
    event ProposalAdded(uint256 indexed proposal,
                        address indexed recipient,
                        uint256 indexed amount,
                        string description);
    event Voted(uint256 indexed proposal,
                bool    indexed position,
                address indexed voter,
                string justification);
    event ProposalTallied(uint256 indexed proposal,
                          uint256 indexed quorum,
                          bool    indexed active);
    event MembershipChanged(address indexed member,
                            bool    indexed isMember);
    event ChangeOfRules(uint256 indexed minimumQuorum,
                        uint256 indexed debatingPeriodInMinutes,
                        int256  indexed majorityMargin);
    struct Proposal {
        address recipient;
        uint256 amount;
        string  description;
        uint256 votingDeadline;
        bool    executed;
        bool    proposalPassed;
        uint256 numberOfVotes;
        int256  currentResult;
        bytes32 proposalHash;
        Vote[]  votes;
        mapping(address => bool) voted;
    }
    struct Member {
        address member;
        string  name;
        uint256 memberSince;
    }
    struct Vote {
        bool    inSupport;
        address voter;
        string  justification;
    }
    modifier onlyMembers {
        if (memberId[msg.sender] == 0) throw;
        _;
    }
    function Congress(
        uint256 minimumQuorumForProposals,
        uint256 minutesForDebate,
        int256  marginOfVotesForMajority,
        address congressLeader
    ) {
        changeVotingRules(minimumQuorumForProposals, minutesForDebate, marginOfVotesForMajority);
        addMember(0, '');  
        if (congressLeader != 0)
            addMember(congressLeader, 'The Founder');
    }
    function addMember(address targetMember, string memberName) onlyOwner {
        if (memberId[targetMember] != 0) throw;
        memberId[targetMember] = members.length;
        members.push(Member({member:      targetMember,
                             memberSince: now,
                             name:        memberName}));
        MembershipChanged(targetMember, true);
    }
    function removeMember(address targetMember) onlyOwner {
        if (memberId[targetMember] == 0) throw;
        uint256 targetId = memberId[targetMember];
        uint256 lastId   = members.length - 1;
        Member memory moved    = members[lastId];
        members[targetId]      = moved; 
        memberId[moved.member] = targetId;
        memberId[targetMember] = 0;
        delete members[lastId];
        --members.length;
        MembershipChanged(targetMember, false);
    }
    function changeVotingRules(
        uint256 minimumQuorumForProposals,
        uint256 minutesForDebate,
        int256  marginOfVotesForMajority
    )
        onlyOwner
    {
        minimumQuorum           = minimumQuorumForProposals;
        debatingPeriodInMinutes = minutesForDebate;
        majorityMargin          = marginOfVotesForMajority;
        ChangeOfRules(minimumQuorum, debatingPeriodInMinutes, majorityMargin);
    }
    function newProposal(
        address beneficiary,
        uint256 amount,
        string  jobDescription,
        bytes   transactionBytecode
    )
        onlyMembers
        returns (uint256 id)
    {
        id               = proposals.length++;
        Proposal p       = proposals[id];
        p.recipient      = beneficiary;
        p.amount         = amount;
        p.description    = jobDescription;
        p.proposalHash   = sha3(beneficiary, amount, transactionBytecode);
        p.votingDeadline = now + debatingPeriodInMinutes * 1 minutes;
        p.executed       = false;
        p.proposalPassed = false;
        p.numberOfVotes  = 0;
        ProposalAdded(id, beneficiary, amount, jobDescription);
    }
    function checkProposalCode(
        uint256 id,
        address beneficiary,
        uint256 amount,
        bytes   transactionBytecode
    )
        constant
        returns (bool codeChecksOut)
    {
        return proposals[id].proposalHash
            == sha3(beneficiary, amount, transactionBytecode);
    }
    function vote(
        uint256 id,
        bool    supportsProposal,
        string  justificationText
    )
        onlyMembers
        returns (uint256 vote)
    {
        Proposal p = proposals[id];              
        if (p.voted[msg.sender] == true) throw;  
        p.voted[msg.sender] = true;              
        p.numberOfVotes++;                       
        if (supportsProposal) {                  
            p.currentResult++;                   
        } else {                                 
            p.currentResult--;                   
        }
        Voted(id,  supportsProposal, msg.sender, justificationText);
    }
    function executeProposal(
        uint256 id,
        bytes   transactionBytecode
    )
        onlyMembers
    {
        Proposal p = proposals[id];
        if (now < p.votingDeadline
            || p.executed
            || p.proposalHash != sha3(p.recipient, p.amount, transactionBytecode)
            || p.numberOfVotes < minimumQuorum)
            throw;
        if (p.currentResult > majorityMargin) {
            p.executed = true;
            if (!p.recipient.call.value(p.amount)(transactionBytecode))
                throw;
            p.proposalPassed = true;
        } else {
            p.proposalPassed = false;
        }
        ProposalTallied(id, p.numberOfVotes, p.proposalPassed);
    }
}
