contract DAOInterface {
    uint constant creationGracePeriod = 40 days;
    uint constant minProposalDebatePeriod = 2 weeks;
    uint constant minSplitDebatePeriod = 1 weeks;
    uint constant splitExecutionPeriod = 27 days;
    uint constant quorumHalvingPeriod = 25 weeks;
    uint constant executeProposalPeriod = 10 days;
    uint constant maxDepositDivisor = 100;
    Proposal[] public proposals;
    uint public minQuorumDivisor;
    uint  public lastTimeMinQuorumMet;
    address public curator;
    mapping (address => bool) public allowedRecipients;
    mapping (address => uint) public rewardToken;
    uint public totalRewardToken;
    ManagedAccount public rewardAccount;
    ManagedAccount public DAOrewardAccount;
    mapping (address => uint) public DAOpaidOut;
    mapping (address => uint) public paidOut;
    mapping (address => uint) public blocked;
    uint public proposalDeposit;
    uint sumOfProposalDeposits;
    DAO_Creator public daoCreator;
    struct Proposal {
        address recipient;
        uint amount;
        string description;
        uint votingDeadline;
        bool open;
        bool proposalPassed;
        bytes32 proposalHash;
        uint proposalDeposit;
        bool newCurator;
        SplitData[] splitData;
        uint yea;
        uint nay;
        mapping (address => bool) votedYes;
        mapping (address => bool) votedNo;
        address creator;
    }
    struct SplitData {
        uint splitBalance;
        uint totalSupply;
        uint rewardToken;
        DAO newDAO;
    }
    modifier onlyTokenholders {}
    function () returns (bool success);
    function receiveEther() returns(bool);
    function newProposal(
        address _recipient,
        uint _amount,
        string _description,
        bytes _transactionData,
        uint _debatingPeriod,
        bool _newCurator
    ) onlyTokenholders returns (uint _proposalID);
    function checkProposalCode(
        uint _proposalID,
        address _recipient,
        uint _amount,
        bytes _transactionData
    ) constant returns (bool _codeChecksOut);
    function vote(
        uint _proposalID,
        bool _supportsProposal
    ) onlyTokenholders returns (uint _voteID);
    function executeProposal(
        uint _proposalID,
        bytes _transactionData
    ) returns (bool _success);
    function splitDAO(
        uint _proposalID,
        address _newCurator
    ) returns (bool _success);
    function newContract(address _newContract);
    function changeAllowedRecipients(address _recipient, bool _allowed) external returns (bool _success);
    function changeProposalDeposit(uint _proposalDeposit) external;
    function retrieveDAOReward(bool _toMembers) external returns (bool _success);
    function getMyReward() returns(bool _success);
    function withdrawRewardFor(address _account) internal returns (bool _success);
    function transferWithoutReward(address _to, uint256 _amount) returns (bool success);
    function transferFromWithoutReward(
        address _from,
        address _to,
        uint256 _amount
    ) returns (bool success);
    function halveMinQuorum() returns (bool _success);
    function numberOfProposals() constant returns (uint _numberOfProposals);
    function getNewDAOAddress(uint _proposalID) constant returns (address _newDAO);
    function isBlocked(address _account) internal returns (bool);
    function unblockMe() returns (bool);
    event ProposalAdded(
        uint indexed proposalID,
        address recipient,
        uint amount,
        bool newCurator,
        string description
    );
    event Voted(uint indexed proposalID, bool position, address indexed voter);
    event ProposalTallied(uint indexed proposalID, bool result, uint quorum);
    event NewCurator(address indexed _newCurator);
    event AllowedRecipientChanged(address indexed _recipient, bool _allowed);
}
