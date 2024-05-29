contract DSToken is DSTokenBase(0), DSStop {
    bytes32  public  symbol = "GENEOS";
    uint256  public  decimals = 18;  
    WhiteList public wlcontract;
    function DSToken(WhiteList wlc_) {
        require(msg.sender == wlc_.owner());
        wlcontract = wlc_;
    }
    function transfer(address dst, uint wad) stoppable note returns (bool) {
        require(wlcontract.whiteList(msg.sender));
        require(wlcontract.whiteList(dst));
        return super.transfer(dst, wad);
    }
    function transferFrom(
        address src, address dst, uint wad
    ) stoppable note returns (bool) {
        require(wlcontract.whiteList(src));
        require(wlcontract.whiteList(dst));
        return super.transferFrom(src, dst, wad);
    }
    function approve(address guy, uint wad) stoppable note returns (bool) {
        require(wlcontract.whiteList(msg.sender));
        require(wlcontract.whiteList(guy));
        return super.approve(guy, wad);
    }
    function push(address dst, uint128 wad) returns (bool) {
        return transfer(dst, wad);
    }
    function pull(address src, uint128 wad) returns (bool) {
        return transferFrom(src, msg.sender, wad);
    }
    function mint(uint128 wad) auth stoppable note {
        require(wlcontract.whiteList(msg.sender));
        _balances[msg.sender] = add(_balances[msg.sender], wad);
        _supply = add(_supply, wad);
    }
    function burn(uint128 wad) auth stoppable note {
        require(wlcontract.whiteList(msg.sender));
        _balances[msg.sender] = sub(_balances[msg.sender], wad);
        _supply = sub(_supply, wad);
    }
    bytes32   public  name = "";
    function setName(bytes32 name_) auth {
        name = name_;
    }
}
