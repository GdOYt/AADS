contract Betting is usingOraclize {
    using SafeMath for uint256;  
    uint countdown=3;  
    address public owner;  
    uint public winnerPoolTotal;
    string public constant version = "0.2.2";
    BettingControllerInterface internal bettingControllerInstance;
    struct chronus_info {
        bool  betting_open;  
        bool  race_start;  
        bool  race_end;  
        bool  voided_bet;  
        uint32  starting_time;  
        uint32  betting_duration;
        uint32  race_duration;  
        uint32 voided_timestamp;
    }
    struct horses_info{
        int64  BTC_delta;  
        int64  ETH_delta;  
        int64  LTC_delta;  
        bytes32 BTC;  
        bytes32 ETH;  
        bytes32 LTC;   
        uint customPreGasLimit;
        uint customPostGasLimit;
    }
    struct bet_info{
        bytes32 horse;  
        uint amount;  
    }
    struct coin_info{
        uint256 pre;  
        uint256 post;  
        uint160 total;  
        uint32 count;  
        bool price_check;
        bytes32 preOraclizeId;
        bytes32 postOraclizeId;
    }
    struct voter_info {
        uint160 total_bet;  
        bool rewarded;  
        mapping(bytes32=>uint) bets;  
    }
    mapping (bytes32 => bytes32) oraclizeIndex;  
    mapping (bytes32 => coin_info) coinIndex;  
    mapping (address => voter_info) voterIndex;  
    uint public total_reward;  
    uint32 total_bettors;
    mapping (bytes32 => bool) public winner_horse;
    event newOraclizeQuery(string description);
    event newPriceTicker(uint price);
    event Deposit(address _from, uint256 _value, bytes32 _horse, uint256 _date);
    event Withdraw(address _to, uint256 _value);
    function Betting() public payable {
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
        owner = msg.sender;
        oraclize_setCustomGasPrice(30000000000 wei);
        horses.BTC = bytes32("BTC");
        horses.ETH = bytes32("ETH");
        horses.LTC = bytes32("LTC");
        horses.customPreGasLimit = 80000;
        horses.customPostGasLimit = 230000;
        bettingControllerInstance = BettingControllerInterface(owner);
    }
    horses_info public horses;
    chronus_info public chronus;
    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }
    modifier duringBetting {
        require(chronus.betting_open);
        require(now < chronus.starting_time + chronus.betting_duration);
        _;
    }
    modifier beforeBetting {
        require(!chronus.betting_open && !chronus.race_start);
        _;
    }
    modifier afterRace {
        require(chronus.race_end);
        _;
    }
    function changeOwnership(address _newOwner) onlyOwner external {
        owner = _newOwner;
    }
    function __callback(bytes32 myid, string result, bytes proof) public {
        require (msg.sender == oraclize_cbAddress());
        require (!chronus.race_end);
        bytes32 coin_pointer;  
        chronus.race_start = true;
        chronus.betting_open = false;
        bettingControllerInstance.remoteBettingClose();
        coin_pointer = oraclizeIndex[myid];
        if (myid == coinIndex[coin_pointer].preOraclizeId) {
            if (coinIndex[coin_pointer].pre > 0) {
            } else if (now >= chronus.starting_time+chronus.betting_duration+ 60 minutes) {
                forceVoidRace();
            } else {
                coinIndex[coin_pointer].pre = stringToUintNormalize(result);
                emit newPriceTicker(coinIndex[coin_pointer].pre);
            }
        } else if (myid == coinIndex[coin_pointer].postOraclizeId){
            if (coinIndex[coin_pointer].pre > 0 ){
                if (coinIndex[coin_pointer].post > 0) {
                } else if (now >= chronus.starting_time+chronus.race_duration+ 60 minutes) {
                    forceVoidRace();
                } else {
                    coinIndex[coin_pointer].post = stringToUintNormalize(result);
                    coinIndex[coin_pointer].price_check = true;
                    emit newPriceTicker(coinIndex[coin_pointer].post);
                    if (coinIndex[horses.ETH].price_check && coinIndex[horses.BTC].price_check && coinIndex[horses.LTC].price_check) {
                        reward();
                    }
                }
            } else {
                forceVoidRace();
            }
        }
    }
    function placeBet(bytes32 horse) external duringBetting payable  {
        require(msg.value >= 0.01 ether);
        if (voterIndex[msg.sender].total_bet==0) {
            total_bettors+=1;
        }
        uint _newAmount = voterIndex[msg.sender].bets[horse] + msg.value;
        voterIndex[msg.sender].bets[horse] = _newAmount;
        voterIndex[msg.sender].total_bet += uint160(msg.value);
        uint160 _newTotal = coinIndex[horse].total + uint160(msg.value); 
        uint32 _newCount = coinIndex[horse].count + 1;
        coinIndex[horse].total = _newTotal;
        coinIndex[horse].count = _newCount;
        emit Deposit(msg.sender, msg.value, horse, now);
    }
    function () private payable {}
    function setupRace(uint delay, uint  locking_duration) onlyOwner beforeBetting public payable returns(bool) {
        if (oraclize_getPrice("URL" , horses.customPreGasLimit)*3 + oraclize_getPrice("URL", horses.customPostGasLimit)*3  > address(this).balance) {
            emit newOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
            return false;
        } else {
            chronus.starting_time = uint32(block.timestamp);
            chronus.betting_open = true;
            bytes32 temp_ID;  
            emit newOraclizeQuery("Oraclize query was sent, standing by for the answer..");
            chronus.betting_duration = uint32(delay);
            temp_ID = oraclize_query(delay, "URL", "json(https://api.coinmarketcap.com/v1/ticker/ethereum/).0.price_usd",horses.customPreGasLimit);
            oraclizeIndex[temp_ID] = horses.ETH;
            coinIndex[horses.ETH].preOraclizeId = temp_ID;
            temp_ID = oraclize_query(delay, "URL", "json(https://api.coinmarketcap.com/v1/ticker/litecoin/).0.price_usd",horses.customPreGasLimit);
            oraclizeIndex[temp_ID] = horses.LTC;
            coinIndex[horses.LTC].preOraclizeId = temp_ID;
            temp_ID = oraclize_query(delay, "URL", "json(https://api.coinmarketcap.com/v1/ticker/bitcoin/).0.price_usd",horses.customPreGasLimit);
            oraclizeIndex[temp_ID] = horses.BTC;
            coinIndex[horses.BTC].preOraclizeId = temp_ID;
            delay = delay.add(locking_duration);
            temp_ID = oraclize_query(delay, "URL", "json(https://api.coinmarketcap.com/v1/ticker/ethereum/).0.price_usd",horses.customPostGasLimit);
            oraclizeIndex[temp_ID] = horses.ETH;
            coinIndex[horses.ETH].postOraclizeId = temp_ID;
            temp_ID = oraclize_query(delay, "URL", "json(https://api.coinmarketcap.com/v1/ticker/litecoin/).0.price_usd",horses.customPostGasLimit);
            oraclizeIndex[temp_ID] = horses.LTC;
            coinIndex[horses.LTC].postOraclizeId = temp_ID;
            temp_ID = oraclize_query(delay, "URL", "json(https://api.coinmarketcap.com/v1/ticker/bitcoin/).0.price_usd",horses.customPostGasLimit);
            oraclizeIndex[temp_ID] = horses.BTC;
            coinIndex[horses.BTC].postOraclizeId = temp_ID;
            chronus.race_duration = uint32(delay);
            return true;
        }
    }
    function reward() internal {
        horses.BTC_delta = int64(coinIndex[horses.BTC].post - coinIndex[horses.BTC].pre)*100000/int64(coinIndex[horses.BTC].pre);
        horses.ETH_delta = int64(coinIndex[horses.ETH].post - coinIndex[horses.ETH].pre)*100000/int64(coinIndex[horses.ETH].pre);
        horses.LTC_delta = int64(coinIndex[horses.LTC].post - coinIndex[horses.LTC].pre)*100000/int64(coinIndex[horses.LTC].pre);
        total_reward = (coinIndex[horses.BTC].total) + (coinIndex[horses.ETH].total) + (coinIndex[horses.LTC].total);
        if (total_bettors <= 1) {
            forceVoidRace();
        } else {
            uint house_fee = total_reward.mul(5).div(100);
            require(house_fee < address(this).balance);
            total_reward = total_reward.sub(house_fee);
            bettingControllerInstance.depositHouseTakeout.value(house_fee)();
        }
        if (horses.BTC_delta > horses.ETH_delta) {
            if (horses.BTC_delta > horses.LTC_delta) {
                winner_horse[horses.BTC] = true;
                winnerPoolTotal = coinIndex[horses.BTC].total;
            }
            else if(horses.LTC_delta > horses.BTC_delta) {
                winner_horse[horses.LTC] = true;
                winnerPoolTotal = coinIndex[horses.LTC].total;
            } else {
                winner_horse[horses.BTC] = true;
                winner_horse[horses.LTC] = true;
                winnerPoolTotal = coinIndex[horses.BTC].total + (coinIndex[horses.LTC].total);
            }
        } else if(horses.ETH_delta > horses.BTC_delta) {
            if (horses.ETH_delta > horses.LTC_delta) {
                winner_horse[horses.ETH] = true;
                winnerPoolTotal = coinIndex[horses.ETH].total;
            }
            else if (horses.LTC_delta > horses.ETH_delta) {
                winner_horse[horses.LTC] = true;
                winnerPoolTotal = coinIndex[horses.LTC].total;
            } else {
                winner_horse[horses.ETH] = true;
                winner_horse[horses.LTC] = true;
                winnerPoolTotal = coinIndex[horses.ETH].total + (coinIndex[horses.LTC].total);
            }
        } else {
            if (horses.LTC_delta > horses.ETH_delta) {
                winner_horse[horses.LTC] = true;
                winnerPoolTotal = coinIndex[horses.LTC].total;
            } else if(horses.LTC_delta < horses.ETH_delta){
                winner_horse[horses.ETH] = true;
                winner_horse[horses.BTC] = true;
                winnerPoolTotal = coinIndex[horses.ETH].total + (coinIndex[horses.BTC].total);
            } else {
                winner_horse[horses.LTC] = true;
                winner_horse[horses.ETH] = true;
                winner_horse[horses.BTC] = true;
                winnerPoolTotal = coinIndex[horses.ETH].total + (coinIndex[horses.BTC].total) + (coinIndex[horses.LTC].total);
            }
        }
        chronus.race_end = true;
    }
    function calculateReward(address candidate) internal afterRace constant returns(uint winner_reward) {
        voter_info storage bettor = voterIndex[candidate];
        if(chronus.voided_bet) {
            winner_reward = bettor.total_bet;
        } else {
            uint winning_bet_total;
            if(winner_horse[horses.BTC]) {
                winning_bet_total += bettor.bets[horses.BTC];
            } if(winner_horse[horses.ETH]) {
                winning_bet_total += bettor.bets[horses.ETH];
            } if(winner_horse[horses.LTC]) {
                winning_bet_total += bettor.bets[horses.LTC];
            }
            winner_reward += (((total_reward.mul(10000000)).div(winnerPoolTotal)).mul(winning_bet_total)).div(10000000);
        } 
    }
    function checkReward() afterRace external constant returns (uint) {
        require(!voterIndex[msg.sender].rewarded);
        return calculateReward(msg.sender);
    }
    function claim_reward() afterRace external {
        require(!voterIndex[msg.sender].rewarded);
        uint transfer_amount = calculateReward(msg.sender);
        require(address(this).balance >= transfer_amount);
        voterIndex[msg.sender].rewarded = true;
        msg.sender.transfer(transfer_amount);
        emit Withdraw(msg.sender, transfer_amount);
    }
    function forceVoidRace() internal {
        chronus.voided_bet=true;
        chronus.race_end = true;
        chronus.voided_timestamp=uint32(now);
    }
    function stringToUintNormalize(string s) internal pure returns (uint result) {
        uint p =2;
        bool precision=false;
        bytes memory b = bytes(s);
        uint i;
        result = 0;
        for (i = 0; i < b.length; i++) {
            if (precision) {p = p-1;}
            if (uint(b[i]) == 46){precision = true;}
            uint c = uint(b[i]);
            if (c >= 48 && c <= 57) {result = result * 10 + (c - 48);}
            if (precision && p == 0){return result;}
        }
        while (p!=0) {
            result = result*10;
            p=p-1;
        }
    }
    function getCoinIndex(bytes32 index, address candidate) external constant returns (uint, uint, uint, bool, uint) {
        return (coinIndex[index].total, coinIndex[index].pre, coinIndex[index].post, coinIndex[index].price_check, voterIndex[candidate].bets[index]);
    }
    function reward_total() external constant returns (uint) {
        return ((coinIndex[horses.BTC].total) + (coinIndex[horses.ETH].total) + (coinIndex[horses.LTC].total));
    }
    function refund() external onlyOwner {
        require(now > chronus.starting_time + chronus.race_duration);
        require((chronus.betting_open && !chronus.race_start)
            || (chronus.race_start && !chronus.race_end));
        chronus.voided_bet = true;
        chronus.race_end = true;
        chronus.voided_timestamp=uint32(now);
        bettingControllerInstance.remoteBettingClose();
    }
    function recovery() external onlyOwner{
        require((chronus.race_end && now > chronus.starting_time + chronus.race_duration + (30 days))
            || (chronus.voided_bet && now > chronus.voided_timestamp + (30 days)));
        bettingControllerInstance.depositHouseTakeout.value(address(this).balance)();
    }
}
