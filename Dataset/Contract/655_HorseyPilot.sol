contract HorseyPilot {
    using SafeMath for uint256;
    event NewProposal(uint8 methodId, uint parameter, address proposer);
    event ProposalPassed(uint8 methodId, uint parameter, address proposer);
    uint8 constant votingThreshold = 2;
    uint256 constant proposalLife = 7 days;
    uint256 constant proposalCooldown = 1 days;
    uint256 cooldownStart;
    address public jokerAddress;
    address public knightAddress;
    address public paladinAddress;
    address[3] public voters;
    uint8 constant public knightEquity = 40;
    uint8 constant public paladinEquity = 10;
    address public exchangeAddress;
    address public tokenAddress;
    mapping(address => uint) internal _cBalance;
    struct Proposal{
        address proposer;            
        uint256 timestamp;           
        uint256 parameter;           
        uint8   methodId;            
        address[] yay;               
        address[] nay;               
    }
    Proposal public currentProposal;
    bool public proposalInProgress = false;
    uint256 public toBeDistributed;
    bool deployed = false;
    constructor(
    address _jokerAddress,
    address _knightAddress,
    address _paladinAddress,
    address[3] _voters
    ) public {
        jokerAddress = _jokerAddress;
        knightAddress = _knightAddress;
        paladinAddress = _paladinAddress;
        for(uint i = 0; i < 3; i++) {
            voters[i] = _voters[i];
        }
        cooldownStart = block.timestamp - proposalCooldown;
    }
    function deployChildren(address stablesAddress) external {
        require(!deployed,"already deployed");
        exchangeAddress = new HorseyExchange();
        tokenAddress = new HorseyToken(stablesAddress);
        HorseyExchange(exchangeAddress).setStables(stablesAddress);
        deployed = true;
    }
    function transferJokerOwnership(address newJoker) external 
    validAddress(newJoker) {
        require(jokerAddress == msg.sender,"Not right role");
        _moveBalance(newJoker);
        jokerAddress = newJoker;
    }
    function transferKnightOwnership(address newKnight) external 
    validAddress(newKnight) {
        require(knightAddress == msg.sender,"Not right role");
        _moveBalance(newKnight);
        knightAddress = newKnight;
    }
    function transferPaladinOwnership(address newPaladin) external 
    validAddress(newPaladin) {
        require(paladinAddress == msg.sender,"Not right role");
        _moveBalance(newPaladin);
        paladinAddress = newPaladin;
    }
    function withdrawCeo(address destination) external 
    onlyCLevelAccess()
    validAddress(destination) {
        if(toBeDistributed > 0){
            _updateDistribution();
        }
        uint256 balance = _cBalance[msg.sender];
        if(balance > 0 && (address(this).balance >= balance)) {
            destination.transfer(balance);  
            _cBalance[msg.sender] = 0;
        }
    }
    function syncFunds() external {
        uint256 prevBalance = address(this).balance;
        HorseyToken(tokenAddress).withdraw();
        HorseyExchange(exchangeAddress).withdraw();
        uint256 newBalance = address(this).balance;
        toBeDistributed = toBeDistributed.add(newBalance - prevBalance);
    }
    function getNobleBalance() external view
    onlyCLevelAccess() returns (uint256) {
        return _cBalance[msg.sender];
    }
    function makeProposal( uint8 methodId, uint256 parameter ) external
    onlyCLevelAccess()
    proposalAvailable()
    cooledDown()
    {
        currentProposal.timestamp = block.timestamp;
        currentProposal.parameter = parameter;
        currentProposal.methodId = methodId;
        currentProposal.proposer = msg.sender;
        delete currentProposal.yay;
        delete currentProposal.nay;
        proposalInProgress = true;
        emit NewProposal(methodId,parameter,msg.sender);
    }
    function voteOnProposal(bool voteFor) external 
    proposalPending()
    onlyVoters()
    notVoted() {
        require((block.timestamp - currentProposal.timestamp) <= proposalLife);
        if(voteFor)
        {
            currentProposal.yay.push(msg.sender);
            if( currentProposal.yay.length >= votingThreshold )
            {
                _doProposal();
                proposalInProgress = false;
                return;
            }
        } else {
            currentProposal.nay.push(msg.sender);
            if( currentProposal.nay.length >= votingThreshold )
            {
                proposalInProgress = false;
                cooldownStart = block.timestamp;
                return;
            }
        }
    }
    function _moveBalance(address newAddress) internal
    validAddress(newAddress) {
        require(newAddress != msg.sender);  
        _cBalance[newAddress] = _cBalance[msg.sender];
        _cBalance[msg.sender] = 0;
    }
    function _updateDistribution() internal {
        require(toBeDistributed != 0,"nothing to distribute");
        uint256 knightPayday = toBeDistributed.div(100).mul(knightEquity);
        uint256 paladinPayday = toBeDistributed.div(100).mul(paladinEquity);
        uint256 jokerPayday = toBeDistributed.sub(knightPayday).sub(paladinPayday);
        _cBalance[jokerAddress] = _cBalance[jokerAddress].add(jokerPayday);
        _cBalance[knightAddress] = _cBalance[knightAddress].add(knightPayday);
        _cBalance[paladinAddress] = _cBalance[paladinAddress].add(paladinPayday);
        toBeDistributed = 0;
    }
    function _doProposal() internal {
        if( currentProposal.methodId == 0 ) HorseyToken(tokenAddress).setRenamingCosts(currentProposal.parameter);
        if( currentProposal.methodId == 1 ) HorseyExchange(exchangeAddress).setMarketFees(currentProposal.parameter);
        if( currentProposal.methodId == 2 ) HorseyToken(tokenAddress).addLegitDevAddress(address(currentProposal.parameter));
        if( currentProposal.methodId == 3 ) HorseyToken(tokenAddress).addHorseIndex(bytes32(currentProposal.parameter));
        if( currentProposal.methodId == 4 ) {
            if(currentProposal.parameter == 0) {
                HorseyExchange(exchangeAddress).unpause();
                HorseyToken(tokenAddress).unpause();
            } else {
                HorseyExchange(exchangeAddress).pause();
                HorseyToken(tokenAddress).pause();
            }
        }
        if( currentProposal.methodId == 5 ) HorseyToken(tokenAddress).setClaimingCosts(currentProposal.parameter);
        if( currentProposal.methodId == 8 ){
            HorseyToken(tokenAddress).setCarrotsMultiplier(uint8(currentProposal.parameter));
        }
        if( currentProposal.methodId == 9 ){
            HorseyToken(tokenAddress).setRarityMultiplier(uint8(currentProposal.parameter));
        }
        emit ProposalPassed(currentProposal.methodId,currentProposal.parameter,currentProposal.proposer);
    }
    modifier validAddress(address addr) {
        require(addr != address(0),"Address is zero");
        _;
    }
    modifier onlyCLevelAccess() {
        require((jokerAddress == msg.sender) || (knightAddress == msg.sender) || (paladinAddress == msg.sender),"not c level");
        _;
    }
    modifier proposalAvailable(){
        require(((!proposalInProgress) || ((block.timestamp - currentProposal.timestamp) > proposalLife)),"proposal already pending");
        _;
    }
    modifier cooledDown( ){
        if(msg.sender == currentProposal.proposer && (block.timestamp - cooldownStart < 1 days)){
            revert("Cool down period not passed yet");
        }
        _;
    }
    modifier proposalPending() {
        require(proposalInProgress,"no proposal pending");
        _;
    }
    modifier notVoted() {
        uint256 length = currentProposal.yay.length;
        for(uint i = 0; i < length; i++) {
            if(currentProposal.yay[i] == msg.sender) {
                revert("Already voted");
            }
        }
        length = currentProposal.nay.length;
        for(i = 0; i < length; i++) {
            if(currentProposal.nay[i] == msg.sender) {
                revert("Already voted");
            }
        }
        _;
    }
    modifier onlyVoters() {
        bool found = false;
        uint256 length = voters.length;
        for(uint i = 0; i < length; i++) {
            if(voters[i] == msg.sender) {
                found = true;
                break;
            }
        }
        if(!found) {
            revert("not a voter");
        }
        _;
    }
}
