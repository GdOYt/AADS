contract TokenLogic is TokenLogicEvents, TokenLogicI, SecuredWithRoles {
    TokenData public data;
    Token public token;      
    bytes32[] public listNames;
    mapping (address => mapping (bytes32 => bool)) public whiteLists;
    bool public freeTransfer = true;
    function TokenLogic(
        address token_,
        address tokenData_,
        address rolesContract) public SecuredWithRoles("TokenLogic", rolesContract)
    {
        require(token_ != address(0x0));
        require(rolesContract != address(0x0));
        token = Token(token_);
        if (tokenData_ == address(0x0)) {
            data = new TokenData(this, msg.sender);
        } else {
            data = TokenData(tokenData_);
        }
    }
    modifier tokenOnly {
        assert(msg.sender == address(token));
        _;
    }
    modifier canTransfer(address src, address dst) {
        require(freeTransfer || src == owner || dst == owner || sameWhiteList(src, dst));
        _;
    }
    function sameWhiteList(address src, address dst) internal view returns(bool) {
        for(uint8 i = 0; i < listNames.length; i++) {
            bytes32 listName = listNames[i];
            if(whiteLists[src][listName] && whiteLists[dst][listName]) {
                return true;
            }
        }
        return false;
    }
    function listNamesLen() public view returns (uint256) {
        return listNames.length;
    }
    function listExists(bytes32 listName) public view returns (bool) {
        var (, ok) = indexOf(listName);
        return ok;
    }
    function indexOf(bytes32 listName) public view returns (uint8, bool) {
        for(uint8 i = 0; i < listNames.length; i++) {
            if(listNames[i] == listName) {
                return (i, true);
            }
        }
        return (0, false);
    }
    function replaceLogic(address newLogic) public onlyOwner {
        token.setLogic(TokenLogicI(newLogic));
        data.setTokenLogic(newLogic);
        selfdestruct(owner);
    }
    function addWhiteList(bytes32 listName) public onlyRole("admin") {
        require(! listExists(listName));
        require(listNames.length < 256);
        listNames.push(listName);
        WhiteListAddition(listName);
    }
    function removeWhiteList(bytes32 listName) public onlyRole("admin") {
        var (i, ok) = indexOf(listName);
        require(ok);
        if(i < listNames.length - 1) {
            listNames[i] = listNames[listNames.length - 1];
        }
        delete listNames[listNames.length - 1];
        --listNames.length;
        WhiteListRemoval(listName);
    }
    function addToWhiteList(bytes32 listName, address guy) public onlyRole("userManager") {
        require(listExists(listName));
        whiteLists[guy][listName] = true;
        AdditionToWhiteList(listName, guy);
    }
    function removeFromWhiteList(bytes32 listName, address guy) public onlyRole("userManager") {
        require(listExists(listName));
        whiteLists[guy][listName] = false;
        RemovalFromWhiteList(listName, guy);
    }
    function setFreeTransfer(bool isFree) public onlyOwner {
        freeTransfer = isFree;
    }
    function setToken(address token_) public onlyOwner {
        token = Token(token_);
    }
    function totalSupply() public view returns (uint256) {
        return data.supply();
    }
    function balanceOf(address src) public view returns (uint256) {
        return data.balances(src);
    }
    function allowance(address src, address spender) public view returns (uint256) {
        return data.approvals(src, spender);
    }
    function transfer(address src, address dst, uint256 wad) public tokenOnly canTransfer(src, dst)  returns (bool) {
        data.setBalances(src, Math.sub(data.balances(src), wad));
        data.setBalances(dst, Math.add(data.balances(dst), wad));
        return true;
    }
    function transferFrom(address src, address dst, uint256 wad) public tokenOnly canTransfer(src, dst)  returns (bool) {
        data.setApprovals(src, dst, Math.sub(data.approvals(src, dst), wad));
        data.setBalances(src, Math.sub(data.balances(src), wad));
        data.setBalances(dst, Math.add(data.balances(dst), wad));
        return true;
    }
    function approve(address src, address dst, uint256 wad) public tokenOnly returns (bool) {
        data.setApprovals(src, dst, wad);
        return true;
    }
    function mintFor(address dst, uint256 wad) public tokenOnly {
        data.setBalances(dst, Math.add(data.balances(dst), wad));
        data.setSupply(Math.add(data.supply(), wad));
    }
    function burn(address src, uint256 wad) public tokenOnly {
        data.setBalances(src, Math.sub(data.balances(src), wad));
        data.setSupply(Math.sub(data.supply(), wad));
    }
}
