contract BBFarmIface is BBFarmEvents, permissioned, hasVersion, payoutAllC {
    function getNamespace() external view returns (bytes4);
    function getBBLibVersion() external view returns (uint256);
    function getNBallots() external view returns (uint256);
    function getVotingNetworkDetails() external view returns (bytes32);
    function initBallot( bytes32 specHash
                       , uint256 packed
                       , IxIface ix
                       , address bbAdmin
                       , bytes24 extraData
                       ) external returns (uint ballotId);
    function initBallotProxy(uint8 v, bytes32 r, bytes32 s, bytes32[4] params) external returns (uint256 ballotId);
    function sponsor(uint ballotId) external payable;
    function submitVote(uint ballotId, bytes32 vote, bytes extra) external;
    function submitProxyVote(bytes32[5] proxyReq, bytes extra) external;
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
            , bytes16 extraData);
    function getVote(uint ballotId, uint voteId) external view returns (bytes32 voteData, address sender, bytes extra);
    function getVoteAndTime(uint ballotId, uint voteId) external view returns (bytes32 voteData, address sender, bytes extra, uint castTs);
    function getTotalSponsorship(uint ballotId) external view returns (uint);
    function getSponsorsN(uint ballotId) external view returns (uint);
    function getSponsor(uint ballotId, uint sponsorN) external view returns (address sender, uint amount);
    function getCreationTs(uint ballotId) external view returns (uint);
    function revealSeckey(uint ballotId, bytes32 sk) external;
    function setEndTime(uint ballotId, uint64 newEndTime) external;   
    function setDeprecated(uint ballotId) external;
    function setBallotOwner(uint ballotId, address newOwner) external;
}
