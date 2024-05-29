contract Arbitrator{
    enum DisputeStatus {Waiting, Appealable, Solved}
    modifier requireArbitrationFee(bytes _extraData) {require(msg.value>=arbitrationCost(_extraData)); _;}
    modifier requireAppealFee(uint _disputeID, bytes _extraData) {require(msg.value>=appealCost(_disputeID, _extraData)); _;}
    event AppealPossible(uint _disputeID);
    event DisputeCreation(uint indexed _disputeID, Arbitrable _arbitrable);
    event AppealDecision(uint indexed _disputeID, Arbitrable _arbitrable);
    function createDispute(uint _choices, bytes _extraData) public requireArbitrationFee(_extraData) payable returns(uint disputeID)  {}
    function arbitrationCost(bytes _extraData) public constant returns(uint fee);
    function appeal(uint _disputeID, bytes _extraData) public requireAppealFee(_disputeID,_extraData) payable {
        emit AppealDecision(_disputeID, Arbitrable(msg.sender));
    }
    function appealCost(uint _disputeID, bytes _extraData) public constant returns(uint fee);
    function disputeStatus(uint _disputeID) public constant returns(DisputeStatus status);
    function currentRuling(uint _disputeID) public constant returns(uint ruling);
}
