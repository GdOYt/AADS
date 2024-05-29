contract BBFarm is BBFarmIface {
    using BBLibV7 for BBLibV7.DB;
    using IxLib for IxIface;
    bytes4 constant NAMESPACE = 0x00000001;
    uint256 constant BALLOT_ID_MASK = 0x00000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    uint constant VERSION = 3;
    mapping (uint224 => BBLibV7.DB) dbs;
    uint nBallots = 0;
    modifier req_namespace(uint ballotId) {
        require(bytes4(ballotId >> 224) == NAMESPACE, "bad-namespace");
        _;
    }
    constructor() payoutAllC(msg.sender) public {
        assert(BBLibV7.getVersion() == 7);
        emit BBFarmInit(NAMESPACE);
    }
    function _getPayTo() internal view returns (address) {
        return owner;
    }
    function getVersion() external pure returns (uint) {
        return VERSION;
    }
    function getNamespace() external view returns (bytes4) {
        return NAMESPACE;
    }
    function getBBLibVersion() external view returns (uint256) {
        return BBLibV7.getVersion();
    }
    function getNBallots() external view returns (uint256) {
        return nBallots;
    }
    function getVotingNetworkDetails() external view returns (bytes32) {
        return bytes32(uint(0) << 192 | uint(0) << 160 | uint160(address(this)));
    }
    function getDb(uint ballotId) internal view returns (BBLibV7.DB storage) {
        return dbs[uint224(ballotId)];
    }
    function initBallot( bytes32 specHash
                       , uint256 packed
                       , IxIface ix
                       , address bbAdmin
                       , bytes24 extraData
                ) only_editors() external returns (uint ballotId) {
        ballotId = uint224(specHash) ^ (uint256(NAMESPACE) << 224);
        getDb(ballotId).init(specHash, packed, ix, bbAdmin, bytes16(uint128(extraData)));
        nBallots += 1;
        emit BallotCreatedWithID(ballotId);
    }
    function initBallotProxy(uint8, bytes32, bytes32, bytes32[4]) external returns (uint256) {
        revert("initBallotProxy not implemented");
    }
    function sponsor(uint ballotId) external payable {
        BBLibV7.DB storage db = getDb(ballotId);
        db.logSponsorship(msg.value);
        doSafeSend(db.index.getPayTo(), msg.value);
        emit Sponsorship(ballotId, msg.value);
    }
    function submitVote(uint ballotId, bytes32 vote, bytes extra) req_namespace(ballotId) external {
        getDb(ballotId).submitVote(vote, extra);
        emit Vote(ballotId, vote, msg.sender, extra);
    }
    function submitProxyVote(bytes32[5] proxyReq, bytes extra) req_namespace(uint256(proxyReq[3])) external {
        uint ballotId = uint256(proxyReq[3]);
        address voter = getDb(ballotId).submitProxyVote(proxyReq, extra);
        bytes32 vote = proxyReq[4];
        emit Vote(ballotId, vote, voter, extra);
    }
    function getDetails(uint ballotId, address voter) external view returns
            ( bool hasVoted
            , uint nVotesCast
            , bytes32 secKey
            , uint16 submissionBits
            , uint64 startTime
            , uint64 endTime
            , bytes32 specHash
            , bool deprecated
            , address ballotOwner
            , bytes16 extraData) {
        BBLibV7.DB storage db = getDb(ballotId);
        uint packed = db.packed;
        return (
            db.getSequenceNumber(voter) > 0,
            db.nVotesCast,
            db.ballotEncryptionSeckey,
            BPackedUtils.packedToSubmissionBits(packed),
            BPackedUtils.packedToStartTime(packed),
            BPackedUtils.packedToEndTime(packed),
            db.specHash,
            db.deprecated,
            db.ballotOwner,
            db.extraData
        );
    }
    function getVote(uint ballotId, uint voteId) external view returns (bytes32 voteData, address sender, bytes extra) {
        (voteData, sender, extra, ) = getDb(ballotId).getVote(voteId);
    }
    function getVoteAndTime(uint ballotId, uint voteId) external view returns (bytes32 voteData, address sender, bytes extra, uint castTs) {
        return getDb(ballotId).getVote(voteId);
    }
    function getSequenceNumber(uint ballotId, address voter) external view returns (uint32 sequence) {
        return getDb(ballotId).getSequenceNumber(voter);
    }
    function getTotalSponsorship(uint ballotId) external view returns (uint) {
        return getDb(ballotId).getTotalSponsorship();
    }
    function getSponsorsN(uint ballotId) external view returns (uint) {
        return getDb(ballotId).sponsors.length;
    }
    function getSponsor(uint ballotId, uint sponsorN) external view returns (address sender, uint amount) {
        return getDb(ballotId).getSponsor(sponsorN);
    }
    function getCreationTs(uint ballotId) external view returns (uint) {
        return getDb(ballotId).creationTs;
    }
    function revealSeckey(uint ballotId, bytes32 sk) external {
        BBLibV7.DB storage db = getDb(ballotId);
        db.requireBallotOwner();
        db.requireBallotClosed();
        db.revealSeckey(sk);
    }
    function setEndTime(uint ballotId, uint64 newEndTime) external {
        BBLibV7.DB storage db = getDb(ballotId);
        db.requireBallotOwner();
        db.requireTesting();
        db.setEndTime(newEndTime);
    }
    function setDeprecated(uint ballotId) external {
        BBLibV7.DB storage db = getDb(ballotId);
        db.requireBallotOwner();
        db.deprecated = true;
    }
    function setBallotOwner(uint ballotId, address newOwner) external {
        BBLibV7.DB storage db = getDb(ballotId);
        db.requireBallotOwner();
        db.ballotOwner = newOwner;
    }
}
