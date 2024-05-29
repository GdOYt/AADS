contract Control {
    using strings for *;
    uint constant REWARD_BASE = 100;
    uint constant REWARD_TAX = 8;
    uint constant REWARD_GET = REWARD_BASE - REWARD_TAX;
    uint constant MAX_ALLBET = 2**120;
    uint constant MIN_BET = 0.001 ether;
    bytes32 constant SHA_DEUCE = keccak256("DEUCE");
    address internal creator;
    address internal owner;
    uint public destroy_time;
    constructor(address target)
    public {
        creator = msg.sender;
        owner = target;
        destroy_time = now + 365 * 24 * 60 * 60;
    }
    function kill()
    external payable {
        require(now >= destroy_time);
        selfdestruct(owner);
    }
    struct PlayerBet {
        uint bet0; 
        uint bet1;
        uint bet2;
        bool drawed;
    }
    struct MatchBet {
        uint betDeadline;
        uint allbet;
        uint allbet0;
        uint allbet1;
        uint allbet2;
        bool ownerDrawed;
        bytes32 SHA_WIN;
        bytes32 SHA_T1;
        bytes32 SHA_T2;
        mapping(address => PlayerBet) list;
    }
    MatchBet[] public MatchList;
    modifier onlyOwner() {
        require(msg.sender == creator || msg.sender == owner);
        _;
    }
    modifier MatchExist(uint index) {
        require(index < MatchList.length);
        _;
    }
    function AddMatch(string troop1, string troop2, uint deadline)
    external
    onlyOwner {
        MatchList.push(MatchBet({
            betDeadline :deadline,
            allbet      :0,
            allbet0     :0,
            allbet1     :0,
            allbet2     :0,
            ownerDrawed :false,
            SHA_T1      :keccak256(bytes(troop1)),
            SHA_T2      :keccak256(bytes(troop2)),
            SHA_WIN     :bytes32(0)
        }));
    }
    function MatchResetDeadline(uint index,uint time)
    external
    onlyOwner MatchExist(index) {
        MatchBet storage oMatch = MatchList[index];
        oMatch.betDeadline = time;
    }
    function MatchEnd(uint index,string winTroop)
    external
    onlyOwner MatchExist(index) {
        MatchBet storage oMatch = MatchList[index];
        require(oMatch.SHA_WIN == 0);
        bytes32 shaWin = keccak256(bytes(winTroop));
        require(shaWin == SHA_DEUCE || shaWin == oMatch.SHA_T1 || shaWin == oMatch.SHA_T2 );
        oMatch.SHA_WIN = shaWin;
    }
    function Bet(uint index, string troop)
    external payable
    MatchExist(index) {
        require(msg.value >= MIN_BET);
        MatchBet storage oMatch = MatchList[index];
        require(oMatch.SHA_WIN == 0 && oMatch.betDeadline >= now);
        uint tempAllBet = oMatch.allbet + msg.value;
        require(tempAllBet > oMatch.allbet && tempAllBet <= MAX_ALLBET);
        PlayerBet storage oBet = oMatch.list[msg.sender];
        oMatch.allbet = tempAllBet;
        bytes32 shaBetTroop = keccak256(bytes(troop));
        if ( shaBetTroop == oMatch.SHA_T1 ) {
            oBet.bet1 += msg.value;
            oMatch.allbet1 += msg.value;
        }
        else if ( shaBetTroop == oMatch.SHA_T2 ) {
            oBet.bet2 += msg.value;
            oMatch.allbet2 += msg.value;
        }
        else {
            require( shaBetTroop == SHA_DEUCE );
            oBet.bet0 += msg.value;
            oMatch.allbet0 += msg.value;
        }
    }
    function CalReward(MatchBet storage oMatch,PlayerBet storage oBet)
    internal view
    returns(uint) {
        uint myWinBet;
        uint allWinBet;
        if ( oMatch.SHA_WIN == oMatch.SHA_T1) {
            myWinBet = oBet.bet1;
            allWinBet = oMatch.allbet1;
        }
        else if ( oMatch.SHA_WIN == oMatch.SHA_T2 ) {
            myWinBet = oBet.bet2;
            allWinBet = oMatch.allbet2;
        }
        else {
            myWinBet = oBet.bet0;
            allWinBet = oMatch.allbet0;
        }
        if (myWinBet == 0) return 0;
        return myWinBet + (oMatch.allbet - allWinBet) * myWinBet / allWinBet * REWARD_GET / REWARD_BASE;
    }
    function Withdraw(uint index,address target)
    public payable
    MatchExist(index) {
        MatchBet storage oMatch = MatchList[index];
        PlayerBet storage oBet = oMatch.list[target];
        if (oBet.drawed) return;
        if (oMatch.SHA_WIN == 0) return;
        uint reward = CalReward(oMatch,oBet);
        if (reward == 0) return;
        oBet.drawed = true;
        target.transfer(reward);
    }
    function WithdrawAll(address target)
    external payable {
        for (uint i=0; i<MatchList.length; i++) {
            Withdraw(i,target);
        }
    }
    function CreatorWithdraw(uint index)
    internal {
        MatchBet storage oMatch = MatchList[index];
        if (oMatch.ownerDrawed) return;
        if (oMatch.SHA_WIN == 0) return;
        oMatch.ownerDrawed = true;
        uint allWinBet;
        if ( oMatch.SHA_WIN == oMatch.SHA_T1) {
            allWinBet = oMatch.allbet1;
        }
        else if ( oMatch.SHA_WIN == oMatch.SHA_T2 ) {
            allWinBet = oMatch.allbet2;
        }
        else {
            allWinBet = oMatch.allbet0;
        }
        if (oMatch.allbet == allWinBet) return;
        if (allWinBet == 0) {
            owner.transfer(oMatch.allbet);
        }
        else {
            uint alltax = (oMatch.allbet - allWinBet) * REWARD_TAX / REWARD_BASE;
            owner.transfer(alltax);
        }
    }
    function CreatorWithdrawAll()
    external payable {
        for (uint i=0; i<MatchList.length; i++) {
            CreatorWithdraw(i);
        }
    }
    function GetMatchLength()
    external view
    returns(uint) {
        return MatchList.length;
    }
    function uint2str(uint i)
    internal pure
    returns (string){
        if (i == 0) return "0";
        uint j = i;
        uint len;
        while (j != 0){
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        while (i != 0){
            bstr[--len] = byte(48 + i % 10);
            i /= 10;
        }
        return string(bstr);
    }
    function GetInfo(MatchBet storage obj,uint idx,address target)
    internal view
    returns(string){
        PlayerBet storage oBet = obj.list[target];
        string memory info = "#";
        info = info.toSlice().concat(uint2str(idx).toSlice());
        info = info.toSlice().concat(",".toSlice()).toSlice().concat(uint2str(oBet.bet1).toSlice());
        info = info.toSlice().concat(",".toSlice()).toSlice().concat(uint2str(obj.allbet1).toSlice());
        info = info.toSlice().concat(",".toSlice()).toSlice().concat(uint2str(oBet.bet2).toSlice());
        info = info.toSlice().concat(",".toSlice()).toSlice().concat(uint2str(obj.allbet2).toSlice());
        info = info.toSlice().concat(",".toSlice()).toSlice().concat(uint2str(oBet.bet0).toSlice());
        info = info.toSlice().concat(",".toSlice()).toSlice().concat(uint2str(obj.allbet0).toSlice());
        if (oBet.drawed) {
            info = info.toSlice().concat(",".toSlice()).toSlice().concat("1".toSlice());
        }
        else {
            info = info.toSlice().concat(",".toSlice()).toSlice().concat("0".toSlice());
        }
        return info;
    }
    function GetDetail(address target)
    external view
    returns(string) {
        string memory res;
        for (uint i=0; i<MatchList.length; i++){
            res = res.toSlice().concat(GetInfo(MatchList[i],i,target).toSlice());
        }
        return res;
    }
}
