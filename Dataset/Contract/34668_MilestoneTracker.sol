contract MilestoneTracker {
    using RLP for RLP.RLPItem;
    using RLP for RLP.Iterator;
    using RLP for bytes;
    struct Milestone {
        string description;      
        string url;              
        uint minCompletionDate;  
        uint maxCompletionDate;  
        address milestoneLeadLink;
        address reviewer;        
        uint reviewTime;         
        address paymentSource;   
        bytes payData;           
        MilestoneStatus status;  
        uint doneTime;           
    }
    Milestone[] public milestones;
    address public recipient;    
    address public donor;        
    address public arbitrator;   
    enum MilestoneStatus {
        AcceptedAndInProgress,
        Completed,
        AuthorizedForPayment,
        Canceled
    }
    bool public campaignCanceled;
    bool public changingMilestones;
    bytes public proposedMilestones;
    modifier onlyRecipient { if (msg.sender !=  recipient) throw; _; }
    modifier onlyArbitrator { if (msg.sender != arbitrator) throw; _; }
    modifier onlyDonor { if (msg.sender != donor) throw; _; }
    modifier campaignNotCanceled { if (campaignCanceled) throw; _; }
    modifier notChanging { if (changingMilestones) throw; _; }
    event NewMilestoneListProposed();
    event NewMilestoneListUnproposed();
    event NewMilestoneListAccepted();
    event ProposalStatusChanged(uint idProposal, MilestoneStatus newProposal);
    event CampaignCanceled();
    function MilestoneTracker (
        address _arbitrator,
        address _donor,
        address _recipient
    ) {
        arbitrator = _arbitrator;
        donor = _donor;
        recipient = _recipient;
    }
    function numberOfMilestones() constant returns (uint) {
        return milestones.length;
    }
    function changeArbitrator(address _newArbitrator) onlyArbitrator {
        arbitrator = _newArbitrator;
    }
    function changeDonor(address _newDonor) onlyDonor {
        donor = _newDonor;
    }
    function changeRecipient(address _newRecipient) onlyRecipient {
        recipient = _newRecipient;
    }
    function proposeMilestones(bytes _newMilestones
    ) onlyRecipient campaignNotCanceled {
        proposedMilestones = _newMilestones;
        changingMilestones = true;
        NewMilestoneListProposed();
    }
    function unproposeMilestones() onlyRecipient campaignNotCanceled {
        delete proposedMilestones;
        changingMilestones = false;
        NewMilestoneListUnproposed();
    }
    function acceptProposedMilestones(bytes32 _hashProposals
    ) onlyDonor campaignNotCanceled {
        uint i;
        if (!changingMilestones) throw;
        if (sha3(proposedMilestones) != _hashProposals) throw;
        for (i=0; i<milestones.length; i++) {
            if (milestones[i].status != MilestoneStatus.AuthorizedForPayment) {
                milestones[i].status = MilestoneStatus.Canceled;
            }
        }
        bytes memory mProposedMilestones = proposedMilestones;
        var itmProposals = mProposedMilestones.toRLPItem(true);
        if (!itmProposals.isList()) throw;
        var itrProposals = itmProposals.iterator();
        while(itrProposals.hasNext()) {
            var itmProposal = itrProposals.next();
            Milestone milestone = milestones[milestones.length ++];
            if (!itmProposal.isList()) throw;
            var itrProposal = itmProposal.iterator();
            milestone.description = itrProposal.next().toAscii();
            milestone.url = itrProposal.next().toAscii();
            milestone.minCompletionDate = itrProposal.next().toUint();
            milestone.maxCompletionDate = itrProposal.next().toUint();
            milestone.milestoneLeadLink = itrProposal.next().toAddress();
            milestone.reviewer = itrProposal.next().toAddress();
            milestone.reviewTime = itrProposal.next().toUint();
            milestone.paymentSource = itrProposal.next().toAddress();
            milestone.payData = itrProposal.next().toData();
            milestone.status = MilestoneStatus.AcceptedAndInProgress;
        }
        delete proposedMilestones;
        changingMilestones = false;
        NewMilestoneListAccepted();
    }
    function markMilestoneComplete(uint _idMilestone)
        campaignNotCanceled notChanging
    {
        if (_idMilestone >= milestones.length) throw;
        Milestone milestone = milestones[_idMilestone];
        if (  (msg.sender != milestone.milestoneLeadLink)
            &&(msg.sender != recipient))
            throw;
        if (milestone.status != MilestoneStatus.AcceptedAndInProgress) throw;
        if (now < milestone.minCompletionDate) throw;
        if (now > milestone.maxCompletionDate) throw;
        milestone.status = MilestoneStatus.Completed;
        milestone.doneTime = now;
        ProposalStatusChanged(_idMilestone, milestone.status);
    }
    function approveCompletedMilestone(uint _idMilestone)
        campaignNotCanceled notChanging
    {
        if (_idMilestone >= milestones.length) throw;
        Milestone milestone = milestones[_idMilestone];
        if ((msg.sender != milestone.reviewer) ||
            (milestone.status != MilestoneStatus.Completed)) throw;
        authorizePayment(_idMilestone);
    }
    function rejectMilestone(uint _idMilestone)
        campaignNotCanceled notChanging
    {
        if (_idMilestone >= milestones.length) throw;
        Milestone milestone = milestones[_idMilestone];
        if ((msg.sender != milestone.reviewer) ||
            (milestone.status != MilestoneStatus.Completed)) throw;
        milestone.status = MilestoneStatus.AcceptedAndInProgress;
        ProposalStatusChanged(_idMilestone, milestone.status);
    }
    function requestMilestonePayment(uint _idMilestone
        ) campaignNotCanceled notChanging {
        if (_idMilestone >= milestones.length) throw;
        Milestone milestone = milestones[_idMilestone];
        if (  (msg.sender != milestone.milestoneLeadLink)
            &&(msg.sender != recipient))
            throw;
        if  ((milestone.status != MilestoneStatus.Completed) ||
             (now < milestone.doneTime + milestone.reviewTime))
            throw;
        authorizePayment(_idMilestone);
    }
    function cancelMilestone(uint _idMilestone)
        onlyRecipient campaignNotCanceled notChanging
    {
        if (_idMilestone >= milestones.length) throw;
        Milestone milestone = milestones[_idMilestone];
        if  ((milestone.status != MilestoneStatus.AcceptedAndInProgress) &&
             (milestone.status != MilestoneStatus.Completed))
            throw;
        milestone.status = MilestoneStatus.Canceled;
        ProposalStatusChanged(_idMilestone, milestone.status);
    }
    function arbitrateApproveMilestone(uint _idMilestone
    ) onlyArbitrator campaignNotCanceled notChanging {
        if (_idMilestone >= milestones.length) throw;
        Milestone milestone = milestones[_idMilestone];
        if  ((milestone.status != MilestoneStatus.AcceptedAndInProgress) &&
             (milestone.status != MilestoneStatus.Completed))
           throw;
        authorizePayment(_idMilestone);
    }
    function arbitrateCancelCampaign() onlyArbitrator campaignNotCanceled {
        campaignCanceled = true;
        CampaignCanceled();
    }
    function authorizePayment(uint _idMilestone) internal {
        if (_idMilestone >= milestones.length) throw;
        Milestone milestone = milestones[_idMilestone];
        if (milestone.status == MilestoneStatus.AuthorizedForPayment) throw;
        milestone.status = MilestoneStatus.AuthorizedForPayment;
        if (!milestone.paymentSource.call.value(0)(milestone.payData))
            throw;
        ProposalStatusChanged(_idMilestone, milestone.status);
    }
}
