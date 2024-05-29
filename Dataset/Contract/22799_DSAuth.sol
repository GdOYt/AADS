contract DSAuth is DSAuthEvents {
    DSAuthority  public  authority;
    address      public  owner;
    function DSAuth() {
        owner = msg.sender;
        LogSetOwner(msg.sender);
    }
    function setOwner(address owner_)
    auth
    {
        owner = owner_;
        LogSetOwner(owner);
    }
    function setAuthority(DSAuthority authority_)
    auth
    {
        authority = authority_;
        LogSetAuthority(authority);
    }
    modifier auth {
        assert(isAuthorized(msg.sender, msg.sig));
        _;
    }
    function isAuthorized(address src, bytes4 sig) internal returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, this, sig);
        }
    }
    function assert(bool x) internal {
        if (!x) throw;
    }
}
