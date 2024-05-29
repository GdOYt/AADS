contract AuctionPack is CardPackFour, Pausable {
    using SafeMath for uint;
    using SafeMath64 for uint64;
    mapping(address => uint) owed;
    event Created(uint indexed id, uint16 proto, uint16 purity, uint minBid, uint length);
    event Opened(uint indexed id, uint64 start);
    event Extended(uint indexed id, uint64 length);
    event Bid(uint indexed id, address indexed bidder, uint value);
    event Claimed(uint indexed id, uint indexed cardID, address indexed bidder, uint value, uint16 proto, uint16 purity);
    event Bonus(uint indexed id, uint indexed cardID, address indexed bidder, uint16 proto, uint16 purity);
    enum Status {
        Closed,
        Open,
        Claimed
    }
    struct Auction {
        Status status;
        uint16 proto;
        uint16 purity;
        uint highestBid;
        address highestBidder;
        uint64 start;
        uint64 length;
        address beneficiary;
        uint16 bonusProto;
        uint16 bonusPurity;
        uint64 bufferPeriod;
        uint minIncreasePercent;
    }
    Auction[] auctions;
    constructor(MigrationInterface _migration) public CardPackFour(_migration) {
    }
    function getAuction(uint id) public view returns (
        Status status,
        uint16 proto,
        uint16 purity,
        uint highestBid,
        address highestBidder,
        uint64 start,
        uint64 length,
        uint16 bonusProto,
        uint16 bonusPurity,
        uint64 bufferPeriod,
        uint minIncreasePercent,
        address beneficiary
    ) {
        require(auctions.length > id);
        Auction memory a = auctions[id];
        return (
            a.status, a.proto, a.purity, a.highestBid, 
            a.highestBidder, a.start, a.length, a.bonusProto, 
            a.bonusPurity, a.bufferPeriod, a.minIncreasePercent, a.beneficiary
        );
    }
    function createAuction(
        address beneficiary, uint16 proto, uint16 purity, 
        uint minBid, uint64 length, uint16 bonusProto, uint16 bonusPurity,
        uint64 bufferPeriod, uint minIncrease
    ) public onlyOwner whenNotPaused returns (uint) {
        require(beneficiary != address(0));
        require(minBid >= 100 wei);
        Auction memory auction = Auction({
            status: Status.Closed,
            proto: proto,
            purity: purity,
            highestBid: minBid,
            highestBidder: address(0),
            start: 0,
            length: length,
            beneficiary: beneficiary,
            bonusProto: bonusProto,
            bonusPurity: bonusPurity,
            bufferPeriod: bufferPeriod,
            minIncreasePercent: minIncrease
        });
        uint id = auctions.push(auction) - 1;
        emit Created(id, proto, purity, minBid, length);
        return id;
    }
    function openAuction(uint id) public onlyOwner {
        Auction storage auction = auctions[id];
        require(auction.status == Status.Closed);
        auction.status = Status.Open;
        auction.start = uint64(block.number);
        emit Opened(id, auction.start);
    }
    function purchase(uint16, address) public payable { 
    }
    function getMinBid(uint id) public view returns (uint) {
        Auction memory auction = auctions[id];
        uint highest = auction.highestBid;
        uint numerator = highest.div(100);
        uint minIncrease = numerator.mul(auction.minIncreasePercent);
        uint threshold = highest + minIncrease;
        return threshold;
    }
    function bid(uint id) public payable {
        Auction storage auction = auctions[id];
        require(auction.status == Status.Open);
        uint64 end = auction.start.add(auction.length);
        require(end >= block.number);
        uint threshold = getMinBid(id);
        require(msg.value >= threshold);
        uint64 differenceToEnd = end.sub(uint64(block.number));
        if (auction.bufferPeriod > differenceToEnd) {
            uint64 toAdd = auction.bufferPeriod.sub(differenceToEnd);
            auction.length = auction.length.add(toAdd);
            emit Extended(id, auction.length);
        }
        emit Bid(id, msg.sender, msg.value);
        if (auction.highestBidder != address(0)) {
            owed[auction.highestBidder] = owed[auction.highestBidder].add(auction.highestBid);
            if (auction.bonusProto != 0) {
                uint cardID = migration.createCard(auction.highestBidder, auction.bonusProto, auction.bonusPurity);
                emit Bonus(id, cardID, auction.highestBidder, auction.bonusProto, auction.bonusPurity);
            }
        }
        auction.highestBid = msg.value;
        auction.highestBidder = msg.sender;
    }
    function claim(uint id) public returns (uint) {
        Auction storage auction = auctions[id];
        uint64 end = auction.start.add(auction.length);
        require(block.number > end);
        require(auction.status == Status.Open);
        auction.status = Status.Claimed;
        uint cardID = migration.createCard(auction.highestBidder, auction.proto, auction.purity);
        emit Claimed(id, cardID, auction.highestBidder, auction.highestBid, auction.proto, auction.purity);
        owed[auction.beneficiary] = owed[auction.beneficiary].add(auction.highestBid);
        return cardID;
    }
    function withdraw(address user) public {
        uint balance = owed[user];
        require(balance > 0);
        owed[user] = 0;
        user.transfer(balance);
    }
    function getOwed(address user) public view returns (uint) {
        return owed[user];
    }
}
