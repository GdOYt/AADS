contract EtherHiLo is usingOraclize, Ownable {
    uint8 constant NUM_DICE_SIDES = 13;
    uint8 constant FAILED_ROLE = 69;
    uint public rngCallbackGas = 500000;
    uint public minBet = 100 finney;
    uint public maxBetThresholdPct = 75;
    bool public gameRunning = false;
    uint public balanceInPlay;
    mapping(address => Game) private gamesInProgress;
    mapping(bytes32 => address) private rollIdToGameAddress;
    mapping(bytes32 => uint) private failedRolls;
    event GameFinished(address indexed player, uint indexed playerGameNumber, uint bet, uint8 firstRoll, uint8 finalRoll, uint winnings, uint payout);
    event GameError(address indexed player, uint indexed playerGameNumber, bytes32 rollId);
    enum BetDirection {
        None,
        Low,
        High
    }
    enum GameState {
        None,
        WaitingForFirstCard,
        WaitingForDirection,
        WaitingForFinalCard,
        Finished
    }
    struct Game {
        address player;
        GameState state;
        uint id;
        BetDirection direction;
        uint bet;
        uint8 firstRoll;
        uint8 finalRoll;
        uint winnings;
    }
    function EtherHiLo() public {
    }
    function() external payable {
    }
    function beginGame() public payable {
        address player = msg.sender;
        uint bet = msg.value;
        require(player != address(0));
        require(gamesInProgress[player].state == GameState.None
                || gamesInProgress[player].state == GameState.Finished,
                "Invalid game state");
        require(gameRunning, "Game is not currently running");
        require(bet >= minBet && bet <= getMaxBet(), "Invalid bet");
        Game memory game = Game({
                id:         uint(keccak256(block.number, player, bet)),
                player:     player,
                state:      GameState.WaitingForFirstCard,
                bet:        bet,
                firstRoll:  0,
                finalRoll:  0,
                winnings:   0,
                direction:  BetDirection.None
            });
        balanceInPlay = SafeMath.add(balanceInPlay, game.bet);
        gamesInProgress[player] = game;
        require(rollDie(player), "Dice roll failed");
    }
    function finishGame(BetDirection direction) public {
        address player = msg.sender;
        require(player != address(0));
        require(gamesInProgress[player].state == GameState.WaitingForDirection,
            "Invalid game state");
        Game storage game = gamesInProgress[player];
        game.direction = direction;
        game.state = GameState.WaitingForFinalCard;
        gamesInProgress[player] = game;
        require(rollDie(player), "Dice roll failed");
    }
    function getGameState(address player) public view returns
            (GameState, uint, BetDirection, uint, uint8, uint8, uint) {
        return (
            gamesInProgress[player].state,
            gamesInProgress[player].id,
            gamesInProgress[player].direction,
            gamesInProgress[player].bet,
            gamesInProgress[player].firstRoll,
            gamesInProgress[player].finalRoll,
            gamesInProgress[player].winnings
        );
    }
    function getMinBet() public view returns (uint) {
        return minBet;
    }
    function getMaxBet() public view returns (uint) {
        return SafeMath.div(SafeMath.div(SafeMath.mul(SafeMath.sub(this.balance, balanceInPlay), maxBetThresholdPct), 100), 12);
    }
    function calculateWinnings(uint bet, uint percent) public pure returns (uint) {
        return SafeMath.div(SafeMath.mul(bet, percent), 100);
    }
    function getLowWinPercent(uint number) public pure returns (uint) {
        require(number >= 2 && number <= NUM_DICE_SIDES, "Invalid number");
        if (number == 2) {
            return 1200;
        } else if (number == 3) {
            return 500;
        } else if (number == 4) {
            return 300;
        } else if (number == 5) {
            return 300;
        } else if (number == 6) {
            return 200;
        } else if (number == 7) {
            return 180;
        } else if (number == 8) {
            return 150;
        } else if (number == 9) {
            return 140;
        } else if (number == 10) {
            return 130;
        } else if (number == 11) {
            return 120;
        } else if (number == 12) {
            return 110;
        } else if (number == 13) {
            return 100;
        }
    }
    function getHighWinPercent(uint number) public pure returns (uint) {
        require(number >= 1 && number < NUM_DICE_SIDES, "Invalid number");
        if (number == 1) {
            return 100;
        } else if (number == 2) {
            return 110;
        } else if (number == 3) {
            return 120;
        } else if (number == 4) {
            return 130;
        } else if (number == 5) {
            return 140;
        } else if (number == 6) {
            return 150;
        } else if (number == 7) {
            return 180;
        } else if (number == 8) {
            return 200;
        } else if (number == 9) {
            return 300;
        } else if (number == 10) {
            return 300;
        } else if (number == 11) {
            return 500;
        } else if (number == 12) {
            return 1200;
        }
    }
    function processDiceRoll(address player, uint8 roll) private {
        Game storage game = gamesInProgress[player];
        if (game.firstRoll == 0) {
            game.firstRoll = roll;
            game.state = GameState.WaitingForDirection;
            gamesInProgress[player] = game;
            return;
        }
        require(gamesInProgress[player].state == GameState.WaitingForFinalCard,
            "Invalid game state");
        uint8 finalRoll = roll;
        uint winnings = 0;
        if (game.direction == BetDirection.High && finalRoll > game.firstRoll) {
            winnings = calculateWinnings(game.bet, getHighWinPercent(game.firstRoll));
        } else if (game.direction == BetDirection.Low && finalRoll < game.firstRoll) {
            winnings = calculateWinnings(game.bet, getLowWinPercent(game.firstRoll));
        }
        uint transferAmount = winnings;
        if (transferAmount > this.balance) {
            if (game.bet < this.balance) {
                transferAmount = game.bet;
            } else {
                transferAmount = SafeMath.div(SafeMath.mul(this.balance, 90), 100);
            }
        }
        balanceInPlay = SafeMath.add(balanceInPlay, game.bet);
        game.finalRoll = finalRoll;
        game.winnings = winnings;
        game.state = GameState.Finished;
        gamesInProgress[player] = game;
        if (transferAmount > 0) {
            game.player.transfer(transferAmount);
        }
        GameFinished(player, game.id, game.bet, game.firstRoll, finalRoll, winnings, transferAmount);
    }
    function rollDie(address player) private returns (bool) {
        bytes32 rollId = oraclize_newRandomDSQuery(0, 7, rngCallbackGas);
        if (failedRolls[rollId] == FAILED_ROLE) {
            delete failedRolls[rollId];
            return false;
        }
        rollIdToGameAddress[rollId] = player;
        return true;
    }
    function __callback(bytes32 rollId, string _result, bytes _proof) public {
        require(msg.sender == oraclize_cbAddress(), "Only Oraclize can call this method");
        address player = rollIdToGameAddress[rollId];
        if (player == address(0)) {
            failedRolls[rollId] = FAILED_ROLE;
            return;
        }
        if (oraclize_randomDS_proofVerify__returnCode(rollId, _result, _proof) != 0) {
            Game storage game = gamesInProgress[player];
            if (game.bet > 0) {
                game.player.transfer(game.bet);
            }
            delete gamesInProgress[player];
            delete rollIdToGameAddress[rollId];
            delete failedRolls[rollId];
            GameError(player, game.id, rollId);
        } else {
            uint8 randomNumber = uint8((uint(keccak256(_result)) % NUM_DICE_SIDES) + 1);
            processDiceRoll(player, randomNumber);
            delete rollIdToGameAddress[rollId];
        }
    }
    function transferBalance(address to, uint amount) public onlyOwner {
        to.transfer(amount);
    }
    function cleanupAbandonedGame(address player) public onlyOwner {
        require(player != address(0));
        Game storage game = gamesInProgress[player];
        require(game.player != address(0));
        game.player.transfer(game.bet);
        delete gamesInProgress[game.player];
    }
    function setRNGCallbackGasConfig(uint gas, uint price) public onlyOwner {
        rngCallbackGas = gas;
        oraclize_setProof(proofType_Ledger);
        oraclize_setCustomGasPrice(price);
    }
    function setMinBet(uint bet) public onlyOwner {
        minBet = bet;
    }
    function setGameRunning(bool v) public onlyOwner {
        gameRunning = v;
    }
    function setMaxBetThresholdPct(uint v) public onlyOwner {
        maxBetThresholdPct = v;
    }
    function destroyAndSend(address _recipient) public onlyOwner {
        selfdestruct(_recipient);
    }
}
