contract Kleros is Arbitrator, ApproveAndCallFallBack {
    Pinakion public pinakion;
    uint public constant NON_PAYABLE_AMOUNT = (2**256 - 2) / 2;  
    RNG public rng;  
    uint public arbitrationFeePerJuror = 0.05 ether;  
    uint16 public defaultNumberJuror = 3;  
    uint public minActivatedToken = 0.1 * 1e18;  
    uint[5] public timePerPeriod;  
    uint public alpha = 2000;  
    uint constant ALPHA_DIVISOR = 1e4;  
    uint public maxAppeals = 5;  
    address public governor;  
    uint public session = 1;       
    uint public lastPeriodChange;  
    uint public segmentSize;       
    uint public rnBlock;           
    uint public randomNumber;      
    enum Period {
        Activation,  
        Draw,        
        Vote,        
        Appeal,      
        Execution    
    }
    Period public period;
    struct Juror {
        uint balance;       
        uint atStake;       
        uint lastSession;   
        uint segmentStart;  
        uint segmentEnd;    
    }
    mapping (address => Juror) public jurors;
    struct Vote {
        address account;  
        uint ruling;      
    }
    struct VoteCounter {
        uint winningChoice;  
        uint winningCount;   
        mapping (uint => uint) voteCount;  
    }
    enum DisputeState {
        Open,        
        Resolving,   
        Executable,  
        Executed     
    }
    struct Dispute {
        Arbitrable arbitrated;        
        uint session;                 
        uint appeals;                 
        uint choices;                 
        uint16 initialNumberJurors;   
        uint arbitrationFeePerJuror;  
        DisputeState state;           
        Vote[][] votes;               
        VoteCounter[] voteCounter;    
        mapping (address => uint) lastSessionVote;  
        uint currentAppealToRepartition;  
        AppealsRepartitioned[] appealsRepartitioned;  
    }
    enum RepartitionStage {  
        Incoherent,
        Coherent,
        AtStake,
        Complete
    }
    struct AppealsRepartitioned {
        uint totalToRedistribute;    
        uint nbCoherent;             
        uint currentIncoherentVote;  
        uint currentCoherentVote;    
        uint currentAtStakeVote;     
        RepartitionStage stage;      
    }
    Dispute[] public disputes;
    event NewPeriod(Period _period, uint indexed _session);
    event TokenShift(address indexed _account, uint _disputeID, int _amount);
    event ArbitrationReward(address indexed _account, uint _disputeID, uint _amount);
    modifier onlyBy(address _account) {require(msg.sender == _account); _;}
    modifier onlyDuring(Period _period) {require(period == _period); _;}
    modifier onlyGovernor() {require(msg.sender == governor); _;}
    constructor(Pinakion _pinakion, RNG _rng, uint[5] _timePerPeriod, address _governor) public {
        pinakion = _pinakion;
        rng = _rng;
        lastPeriodChange = now;
        timePerPeriod = _timePerPeriod;
        governor = _governor;
    }
    function receiveApproval(address _from, uint _amount, address, bytes) public onlyBy(pinakion) {
        require(pinakion.transferFrom(_from, this, _amount));
        jurors[_from].balance += _amount;
    }
    function withdraw(uint _value) public {
        Juror storage juror = jurors[msg.sender];
        require(juror.atStake <= juror.balance);  
        require(_value <= juror.balance-juror.atStake);
        require(juror.lastSession != session);
        juror.balance -= _value;
        require(pinakion.transfer(msg.sender,_value));
    }
    function passPeriod() public {
        require(now-lastPeriodChange >= timePerPeriod[uint8(period)]);
        if (period == Period.Activation) {
            rnBlock = block.number + 1;
            rng.requestRN(rnBlock);
            period = Period.Draw;
        } else if (period == Period.Draw) {
            randomNumber = rng.getUncorrelatedRN(rnBlock);
            require(randomNumber != 0);
            period = Period.Vote;
        } else if (period == Period.Vote) {
            period = Period.Appeal;
        } else if (period == Period.Appeal) {
            period = Period.Execution;
        } else if (period == Period.Execution) {
            period = Period.Activation;
            ++session;
            segmentSize = 0;
            rnBlock = 0;
            randomNumber = 0;
        }
        lastPeriodChange = now;
        NewPeriod(period, session);
    }
    function activateTokens(uint _value) public onlyDuring(Period.Activation) {
        Juror storage juror = jurors[msg.sender];
        require(_value <= juror.balance);
        require(_value >= minActivatedToken);
        require(juror.lastSession != session);  
        juror.lastSession = session;
        juror.segmentStart = segmentSize;
        segmentSize += _value;
        juror.segmentEnd = segmentSize;
    }
    function voteRuling(uint _disputeID, uint _ruling, uint[] _draws) public onlyDuring(Period.Vote) {
        Dispute storage dispute = disputes[_disputeID];
        Juror storage juror = jurors[msg.sender];
        VoteCounter storage voteCounter = dispute.voteCounter[dispute.appeals];
        require(dispute.lastSessionVote[msg.sender] != session);  
        require(_ruling <= dispute.choices);
        require(validDraws(msg.sender, _disputeID, _draws));
        dispute.lastSessionVote[msg.sender] = session;
        voteCounter.voteCount[_ruling] += _draws.length;
        if (voteCounter.winningCount < voteCounter.voteCount[_ruling]) {
            voteCounter.winningCount = voteCounter.voteCount[_ruling];
            voteCounter.winningChoice = _ruling;
        } else if (voteCounter.winningCount==voteCounter.voteCount[_ruling] && _draws.length!=0) {  
            voteCounter.winningChoice = 0;  
        }
        for (uint i = 0; i < _draws.length; ++i) {
            dispute.votes[dispute.appeals].push(Vote({
                account: msg.sender,
                ruling: _ruling
            }));
        }
        juror.atStake += _draws.length * getStakePerDraw();
        uint feeToPay = _draws.length * dispute.arbitrationFeePerJuror;
        msg.sender.transfer(feeToPay);
        ArbitrationReward(msg.sender, _disputeID, feeToPay);
    }
    function penalizeInactiveJuror(address _jurorAddress, uint _disputeID, uint[] _draws) public {
        Dispute storage dispute = disputes[_disputeID];
        Juror storage inactiveJuror = jurors[_jurorAddress];
        require(period > Period.Vote);
        require(dispute.lastSessionVote[_jurorAddress] != session);  
        dispute.lastSessionVote[_jurorAddress] = session;  
        require(validDraws(_jurorAddress, _disputeID, _draws));
        uint penality = _draws.length * minActivatedToken * 2 * alpha / ALPHA_DIVISOR;
        penality = (penality < inactiveJuror.balance) ? penality : inactiveJuror.balance;  
        inactiveJuror.balance -= penality;
        TokenShift(_jurorAddress, _disputeID, -int(penality));
        jurors[msg.sender].balance += penality / 2;  
        TokenShift(msg.sender, _disputeID, int(penality / 2));
        jurors[governor].balance += penality / 2;  
        TokenShift(governor, _disputeID, int(penality / 2));
        msg.sender.transfer(_draws.length*dispute.arbitrationFeePerJuror);  
    }
    function oneShotTokenRepartition(uint _disputeID) public onlyDuring(Period.Execution) {
        Dispute storage dispute = disputes[_disputeID];
        require(dispute.state == DisputeState.Open);
        require(dispute.session+dispute.appeals <= session);
        uint winningChoice = dispute.voteCounter[dispute.appeals].winningChoice;
        uint amountShift = getStakePerDraw();
        for (uint i = 0; i <= dispute.appeals; ++i) {
            if (winningChoice!=0 || (dispute.voteCounter[dispute.appeals].voteCount[0] == dispute.voteCounter[dispute.appeals].winningCount)) {
                uint totalToRedistribute = 0;
                uint nbCoherent = 0;
                for (uint j = 0; j < dispute.votes[i].length; ++j) {
                    Vote storage vote = dispute.votes[i][j];
                    if (vote.ruling != winningChoice) {
                        Juror storage juror = jurors[vote.account];
                        uint penalty = amountShift<juror.balance ? amountShift : juror.balance;
                        juror.balance -= penalty;
                        TokenShift(vote.account, _disputeID, int(-penalty));
                        totalToRedistribute += penalty;
                    } else {
                        ++nbCoherent;
                    }
                }
                if (nbCoherent == 0) {  
                    jurors[governor].balance += totalToRedistribute;
                    TokenShift(governor, _disputeID, int(totalToRedistribute));
                } else {  
                    uint toRedistribute = totalToRedistribute / nbCoherent;  
                    for (j = 0; j < dispute.votes[i].length; ++j) {
                        vote = dispute.votes[i][j];
                        if (vote.ruling == winningChoice) {
                            juror = jurors[vote.account];
                            juror.balance += toRedistribute;
                            TokenShift(vote.account, _disputeID, int(toRedistribute));
                        }
                    }
                }
            }
            for (j = 0; j < dispute.votes[i].length; ++j) {
                vote = dispute.votes[i][j];
                juror = jurors[vote.account];
                juror.atStake -= amountShift;  
            }
        }
        dispute.state = DisputeState.Executable;  
    }
    function multipleShotTokenRepartition(uint _disputeID, uint _maxIterations) public onlyDuring(Period.Execution) {
        Dispute storage dispute = disputes[_disputeID];
        require(dispute.state <= DisputeState.Resolving);
        require(dispute.session+dispute.appeals <= session);
        dispute.state = DisputeState.Resolving;  
        uint winningChoice = dispute.voteCounter[dispute.appeals].winningChoice;
        uint amountShift = getStakePerDraw();
        uint currentIterations = 0;  
        for (uint i = dispute.currentAppealToRepartition; i <= dispute.appeals; ++i) {
            if (dispute.appealsRepartitioned.length < i+1) {
                dispute.appealsRepartitioned.length++;
            }
            if (winningChoice==0 && (dispute.voteCounter[dispute.appeals].voteCount[0] != dispute.voteCounter[dispute.appeals].winningCount)) {
                dispute.appealsRepartitioned[i].stage = RepartitionStage.AtStake;
            }
            if (dispute.appealsRepartitioned[i].stage == RepartitionStage.Incoherent) {
                for (uint j = dispute.appealsRepartitioned[i].currentIncoherentVote; j < dispute.votes[i].length; ++j) {
                    if (currentIterations >= _maxIterations) {
                        return;
                    }
                    Vote storage vote = dispute.votes[i][j];
                    if (vote.ruling != winningChoice) {
                        Juror storage juror = jurors[vote.account];
                        uint penalty = amountShift<juror.balance ? amountShift : juror.balance;
                        juror.balance -= penalty;
                        TokenShift(vote.account, _disputeID, int(-penalty));
                        dispute.appealsRepartitioned[i].totalToRedistribute += penalty;
                    } else {
                        ++dispute.appealsRepartitioned[i].nbCoherent;
                    }
                    ++dispute.appealsRepartitioned[i].currentIncoherentVote;
                    ++currentIterations;
                }
                dispute.appealsRepartitioned[i].stage = RepartitionStage.Coherent;
            }
            if (dispute.appealsRepartitioned[i].stage == RepartitionStage.Coherent) {
                if (dispute.appealsRepartitioned[i].nbCoherent == 0) {  
                    jurors[governor].balance += dispute.appealsRepartitioned[i].totalToRedistribute;
                    TokenShift(governor, _disputeID, int(dispute.appealsRepartitioned[i].totalToRedistribute));
                    dispute.appealsRepartitioned[i].stage = RepartitionStage.AtStake;
                } else {  
                    uint toRedistribute = dispute.appealsRepartitioned[i].totalToRedistribute / dispute.appealsRepartitioned[i].nbCoherent;  
                    for (j = dispute.appealsRepartitioned[i].currentCoherentVote; j < dispute.votes[i].length; ++j) {
                        if (currentIterations >= _maxIterations) {
                            return;
                        }
                        vote = dispute.votes[i][j];
                        if (vote.ruling == winningChoice) {
                            juror = jurors[vote.account];
                            juror.balance += toRedistribute;
                            TokenShift(vote.account, _disputeID, int(toRedistribute));
                        }
                        ++currentIterations;
                        ++dispute.appealsRepartitioned[i].currentCoherentVote;
                    }
                    dispute.appealsRepartitioned[i].stage = RepartitionStage.AtStake;
                }
            }
            if (dispute.appealsRepartitioned[i].stage == RepartitionStage.AtStake) {
                for (j = dispute.appealsRepartitioned[i].currentAtStakeVote; j < dispute.votes[i].length; ++j) {
                    if (currentIterations >= _maxIterations) {
                        return;
                    }
                    vote = dispute.votes[i][j];
                    juror = jurors[vote.account];
                    juror.atStake -= amountShift;  
                    ++currentIterations;
                    ++dispute.appealsRepartitioned[i].currentAtStakeVote;
                }
                dispute.appealsRepartitioned[i].stage = RepartitionStage.Complete;
            }
            if (dispute.appealsRepartitioned[i].stage == RepartitionStage.Complete) {
                ++dispute.currentAppealToRepartition;
            }
        }
        dispute.state = DisputeState.Executable;
    }
    function amountJurors(uint _disputeID) public view returns (uint nbJurors) {
        Dispute storage dispute = disputes[_disputeID];
        return (dispute.initialNumberJurors + 1) * 2**dispute.appeals - 1;
    }
    function validDraws(address _jurorAddress, uint _disputeID, uint[] _draws) public view returns (bool valid) {
        uint draw = 0;
        Juror storage juror = jurors[_jurorAddress];
        Dispute storage dispute = disputes[_disputeID];
        uint nbJurors = amountJurors(_disputeID);
        if (juror.lastSession != session) return false;  
        if (dispute.session+dispute.appeals != session) return false;  
        if (period <= Period.Draw) return false;  
        for (uint i = 0; i < _draws.length; ++i) {
            if (_draws[i] <= draw) return false;  
            draw = _draws[i];
            if (draw > nbJurors) return false;
            uint position = uint(keccak256(randomNumber, _disputeID, draw)) % segmentSize;  
            require(position >= juror.segmentStart);
            require(position < juror.segmentEnd);
        }
        return true;
    }
    function createDispute(uint _choices, bytes _extraData) public payable returns (uint disputeID) {
        uint16 nbJurors = extraDataToNbJurors(_extraData);
        require(msg.value >= arbitrationCost(_extraData));
        disputeID = disputes.length++;
        Dispute storage dispute = disputes[disputeID];
        dispute.arbitrated = Arbitrable(msg.sender);
        if (period < Period.Draw)  
            dispute.session = session;
        else  
            dispute.session = session+1;
        dispute.choices = _choices;
        dispute.initialNumberJurors = nbJurors;
        dispute.arbitrationFeePerJuror = arbitrationFeePerJuror;  
        dispute.votes.length++;
        dispute.voteCounter.length++;
        DisputeCreation(disputeID, Arbitrable(msg.sender));
        return disputeID;
    }
    function appeal(uint _disputeID, bytes _extraData) public payable onlyDuring(Period.Appeal) {
        super.appeal(_disputeID,_extraData);
        Dispute storage dispute = disputes[_disputeID];
        require(msg.value >= appealCost(_disputeID, _extraData));
        require(dispute.session+dispute.appeals == session);  
        require(dispute.arbitrated == msg.sender);
        dispute.appeals++;
        dispute.votes.length++;
        dispute.voteCounter.length++;
    }
    function executeRuling(uint disputeID) public {
        Dispute storage dispute = disputes[disputeID];
        require(dispute.state == DisputeState.Executable);
        dispute.state = DisputeState.Executed;
        dispute.arbitrated.rule(disputeID, dispute.voteCounter[dispute.appeals].winningChoice);
    }
    function arbitrationCost(bytes _extraData) public view returns (uint fee) {
        return extraDataToNbJurors(_extraData) * arbitrationFeePerJuror;
    }
    function appealCost(uint _disputeID, bytes _extraData) public view returns (uint fee) {
        Dispute storage dispute = disputes[_disputeID];
        if(dispute.appeals >= maxAppeals) return NON_PAYABLE_AMOUNT;
        return (2*amountJurors(_disputeID) + 1) * dispute.arbitrationFeePerJuror;
    }
    function extraDataToNbJurors(bytes _extraData) internal view returns (uint16 nbJurors) {
        if (_extraData.length < 2)
            return defaultNumberJuror;
        else
            return (uint16(_extraData[0]) << 8) + uint16(_extraData[1]);
    }
    function getStakePerDraw() public view returns (uint minActivatedTokenInAlpha) {
        return (alpha * minActivatedToken) / ALPHA_DIVISOR;
    }
    function getVoteAccount(uint _disputeID, uint _appeals, uint _voteID) public view returns (address account) {
        return disputes[_disputeID].votes[_appeals][_voteID].account;
    }
    function getVoteRuling(uint _disputeID, uint _appeals, uint _voteID) public view returns (uint ruling) {
        return disputes[_disputeID].votes[_appeals][_voteID].ruling;
    }
    function getWinningChoice(uint _disputeID, uint _appeals) public view returns (uint winningChoice) {
        return disputes[_disputeID].voteCounter[_appeals].winningChoice;
    }
    function getWinningCount(uint _disputeID, uint _appeals) public view returns (uint winningCount) {
        return disputes[_disputeID].voteCounter[_appeals].winningCount;
    }
    function getVoteCount(uint _disputeID, uint _appeals, uint _choice) public view returns (uint voteCount) {
        return disputes[_disputeID].voteCounter[_appeals].voteCount[_choice];
    }
    function getLastSessionVote(uint _disputeID, address _juror) public view returns (uint lastSessionVote) {
        return disputes[_disputeID].lastSessionVote[_juror];
    }
    function isDrawn(uint _disputeID, address _juror, uint _draw) public view returns (bool drawn) {
        Dispute storage dispute = disputes[_disputeID];
        Juror storage juror = jurors[_juror];
        if (juror.lastSession != session
        || (dispute.session+dispute.appeals != session)
        || period<=Period.Draw
        || _draw>amountJurors(_disputeID)
        || _draw==0
        || segmentSize==0
        ) {
            return false;
        } else {
            uint position = uint(keccak256(randomNumber,_disputeID,_draw)) % segmentSize;
            return (position >= juror.segmentStart) && (position < juror.segmentEnd);
        }
    }
    function currentRuling(uint _disputeID) public view returns (uint ruling) {
        Dispute storage dispute = disputes[_disputeID];
        return dispute.voteCounter[dispute.appeals].winningChoice;
    }
    function disputeStatus(uint _disputeID) public view returns (DisputeStatus status) {
        Dispute storage dispute = disputes[_disputeID];
        if (dispute.session+dispute.appeals < session)  
            return DisputeStatus.Solved;
        else if(dispute.session+dispute.appeals == session) {  
            if (dispute.state == DisputeState.Open) {
                if (period < Period.Appeal)
                    return DisputeStatus.Waiting;
                else if (period == Period.Appeal)
                    return DisputeStatus.Appealable;
                else return DisputeStatus.Solved;
            } else return DisputeStatus.Solved;
        } else return DisputeStatus.Waiting;  
    }
    function executeOrder(bytes32 _data, uint _value, address _target) public onlyGovernor {
        _target.call.value(_value)(_data);
    }
    function setRng(RNG _rng) public onlyGovernor {
        rng = _rng;
    }
    function setArbitrationFeePerJuror(uint _arbitrationFeePerJuror) public onlyGovernor {
        arbitrationFeePerJuror = _arbitrationFeePerJuror;
    }
    function setDefaultNumberJuror(uint16 _defaultNumberJuror) public onlyGovernor {
        defaultNumberJuror = _defaultNumberJuror;
    }
    function setMinActivatedToken(uint _minActivatedToken) public onlyGovernor {
        minActivatedToken = _minActivatedToken;
    }
    function setTimePerPeriod(uint[5] _timePerPeriod) public onlyGovernor {
        timePerPeriod = _timePerPeriod;
    }
    function setAlpha(uint _alpha) public onlyGovernor {
        alpha = _alpha;
    }
    function setMaxAppeals(uint _maxAppeals) public onlyGovernor {
        maxAppeals = _maxAppeals;
    }
    function setGovernor(address _governor) public onlyGovernor {
        governor = _governor;
    }
}
