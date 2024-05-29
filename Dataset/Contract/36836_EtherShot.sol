contract EtherShot is usingOraclize, SafeAddSub {
    bool public gamePaused;
    address public owner;
    uint constant public TicketsInGame = 100;
    uint constant public WeiPerTicket = 100000000000000000;  
    uint public TicketsSoldForThisGame;
    uint public GameNumber;
    uint public Jackpot = 0;
    uint nBytes = 1;
    uint oraclizeFees = 0;
    address[256] tickets;
    enum oraclizeState {Called, Returned}
    mapping (bytes32 => oraclizeState) queryIds;
    mapping (bytes32 => uint) queriesByGame;
    mapping (address => uint) playerPendingWithdrawals;
    uint constant callbackGas = 250000;
    modifier gameIsActive {
        require(gamePaused != true);
        _;
    }
    modifier ticketsAvailable {
        require(TicketsSoldForThisGame < TicketsInGame);
        _;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    modifier allTicketsSold {
        require(TicketsSoldForThisGame == TicketsInGame);
        _;
    }
    modifier onlyOraclize {
        require(msg.sender == oraclize_cbAddress());
        _;
    }
    modifier isForActiveGame(bytes32 _queryId) {
        require(queryIds[_queryId] == oraclizeState.Called);
        require(queriesByGame[_queryId] == GameNumber);
        _;
    }
    event LogTicket(uint InGameNumber, address indexed PlayerAddress, uint TicketsPurchased);
    event LogResultWinner(uint InGameNumber, address indexed PlayerAddress, uint WinningTicketNumber, uint JackpotWon, bytes Proof);
    event LogResultNoWinner(uint InGameNumber, uint WinningTicketNumber, bytes Proof);
    function EtherShot(){
        oraclize_setProof(proofType_Ledger);
        owner = msg.sender;
        tickets[0] = owner;
        GameNumber = 1;
        TicketsSoldForThisGame = 1;
    }
    function()
    payable
    gameIsActive
    ticketsAvailable
    {
        require(msg.value >= WeiPerTicket);
        uint iterations = (msg.value / WeiPerTicket);
        bool firstBet = TicketsSoldForThisGame == 1;
        uint playerTickets = 0;
        for (uint x = 0; x < (TicketsInGame - 2) && TicketsSoldForThisGame < TicketsInGame && x < iterations; x++) {
            tickets[TicketsSoldForThisGame++] = msg.sender;
            playerTickets = safeAdd(playerTickets, 1);
        }
        LogTicket(GameNumber, msg.sender, playerTickets);
        Jackpot = safeSub(((TicketsSoldForThisGame - 1) * WeiPerTicket), oraclizeFees);
        if (!firstBet) {
            oraclizeFees = safeAdd(oraclizeFees, oraclize_getPrice("random", callbackGas));
            bytes32 queryId = oraclize_newRandomDSQuery(0, nBytes, callbackGas);
            queryIds[queryId] = oraclizeState.Called;
            queriesByGame[queryId] = GameNumber;
        }
        uint refundableAmount = safeSub(msg.value, (playerTickets * WeiPerTicket));
        if (refundableAmount > 0 && !msg.sender.send(refundableAmount)) {
            playerPendingWithdrawals[msg.sender] = safeAdd(playerPendingWithdrawals[msg.sender], refundableAmount);
        }
    }
    function __callback(bytes32 _queryId, string _result, bytes _proof)
    gameIsActive
    onlyOraclize
    isForActiveGame(_queryId)
    oraclize_randomDS_proofVerify(_queryId, _result, _proof)
    {
        queryIds[_queryId] = oraclizeState.Returned;
        var result = bytesToInt(bytes(_result)) % TicketsInGame;
        if (result > (TicketsSoldForThisGame - 1)) {
            LogResultNoWinner(GameNumber, result + 1, _proof);
        }
        else {
            uint payout = ((TicketsSoldForThisGame - 1) * WeiPerTicket) - oraclizeFees;
            TicketsSoldForThisGame = 1;
            GameNumber++;
            oraclizeFees = 0;
            Jackpot = 0;
            var winningPlayer = tickets[result];
            if (!winningPlayer.send(payout)) {
                playerPendingWithdrawals[winningPlayer] = safeAdd(playerPendingWithdrawals[winningPlayer], payout);
            }
            LogResultWinner(GameNumber - 1, winningPlayer, result + 1, payout, _proof);
        }
    }
    function bytesToInt(bytes _inputBytes) constant internal returns (uint resultInt){
        resultInt = 0;
        for (uint i = 0; i < _inputBytes.length; i++) {
            resultInt += uint(_inputBytes[i]) * (2 ** (i * 8));
        }
        return resultInt;
    }
    function playerWithdrawPendingTransactions() public
    returns (bool)
    {
        uint withdrawAmount = playerPendingWithdrawals[msg.sender];
        playerPendingWithdrawals[msg.sender] = 0;
        if (msg.sender.call.value(withdrawAmount)()) {
            return true;
        }
        else {
            playerPendingWithdrawals[msg.sender] = withdrawAmount;
            return false;
        }
    }
    function playerGetPendingTxByAddress(address addressToCheck) public constant returns (uint) {
        return playerPendingWithdrawals[addressToCheck];
    }
    function retriggerDrawOnOraclizeError() public
    onlyOwner
    allTicketsSold
    {
        oraclizeFees = safeAdd(oraclizeFees, oraclize_getPrice("random", callbackGas));
        Jackpot = safeSub(((TicketsSoldForThisGame - 1) * WeiPerTicket), oraclizeFees);
        bytes32 queryId = oraclize_newRandomDSQuery(0, nBytes, callbackGas);
        queryIds[queryId] = oraclizeState.Called;
    }
    function deployNewContract() public
    onlyOwner
    {
        selfdestruct(owner);
    }
}
