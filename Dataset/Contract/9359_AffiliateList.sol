contract AffiliateList is Ownable, IAffiliateList {
    event AffiliateAdded(address addr, uint startTimestamp, uint endTimestamp);
    event AffiliateUpdated(address addr, uint startTimestamp, uint endTimestamp);
    mapping (address => uint) public affiliateStart;
    mapping (address => uint) public affiliateEnd;
    function set(address addr, uint startTimestamp, uint endTimestamp) public onlyOwner {
        require(addr != address(0));
        uint existingStart = affiliateStart[addr];
        if(existingStart == 0) {
            require(startTimestamp != 0);
            affiliateStart[addr] = startTimestamp;
            if(endTimestamp != 0) {
                require(endTimestamp > startTimestamp);
                affiliateEnd[addr] = endTimestamp;
            }
            emit AffiliateAdded(addr, startTimestamp, endTimestamp);
        }
        else {
            if(startTimestamp == 0) {
                if(endTimestamp == 0) {
                    affiliateStart[addr] = 0;
                    affiliateEnd[addr] = 0;
                }
                else {
                    require(endTimestamp > existingStart);
                }
            }
            else {
                affiliateStart[addr] = startTimestamp;
                if(endTimestamp != 0) {
                    require(endTimestamp > startTimestamp);
                }
            }
            affiliateEnd[addr] = endTimestamp;
            emit AffiliateUpdated(addr, startTimestamp, endTimestamp);
        }
    }
    function get(address addr) public view returns (uint start, uint end) {
        return (affiliateStart[addr], affiliateEnd[addr]);
    }
    function inListAsOf(address addr, uint time) public view returns (bool) {
        uint start;
        uint end;
        (start, end) = get(addr);
        if(start == 0) {
            return false;
        }
        if(time < start) {
            return false;
        }
        if(end != 0 && time >= end) {
            return false;
        }
        return true;
    }
}
