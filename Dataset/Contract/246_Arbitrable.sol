contract Arbitrable{
    Arbitrator public arbitrator;
    bytes public arbitratorExtraData;  
    modifier onlyArbitrator {require(msg.sender==address(arbitrator)); _;}
    event Ruling(Arbitrator indexed _arbitrator, uint indexed _disputeID, uint _ruling);
    event MetaEvidence(uint indexed _metaEvidenceID, string _evidence);
    event Dispute(Arbitrator indexed _arbitrator, uint indexed _disputeID, uint _metaEvidenceID);
    event Evidence(Arbitrator indexed _arbitrator, uint indexed _disputeID, address _party, string _evidence);
    constructor(Arbitrator _arbitrator, bytes _arbitratorExtraData) public {
        arbitrator = _arbitrator;
        arbitratorExtraData = _arbitratorExtraData;
    }
    function rule(uint _disputeID, uint _ruling) public onlyArbitrator {
        emit Ruling(Arbitrator(msg.sender),_disputeID,_ruling);
        executeRuling(_disputeID,_ruling);
    }
    function executeRuling(uint _disputeID, uint _ruling) internal;
}
