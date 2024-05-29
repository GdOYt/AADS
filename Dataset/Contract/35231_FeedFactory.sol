contract FeedFactory {
    event Created(address indexed sender, address feed);
    mapping(address=>bool) public isFeed;
    function create() public returns (PriceFeed) {
        PriceFeed feed = new PriceFeed();
        Created(msg.sender, address(feed));
        feed.setOwner(msg.sender);
        isFeed[feed] = true;
        return feed;
    }
}
