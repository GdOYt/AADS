contract Token is TokenI, SecuredWithRoles, TokenEvents {
    string public symbol;
    string public name;  
    uint8 public decimals = 18;  
    TokenLogicI public logic;
    function Token(string name_, string symbol_, address rolesContract) public SecuredWithRoles(name_, rolesContract) {
        name = name_;
        symbol = symbol_;
    }
    modifier logicOnly {
        require(address(logic) == address(0x0) || address(logic) == msg.sender);
        _;
    }
    function totalSupply() public view returns (uint256) {
        return logic.totalSupply();
    }
    function balanceOf( address who ) public view returns (uint256 value) {
        return logic.balanceOf(who);
    }
    function allowance(address owner, address spender ) public view returns (uint256 _allowance) {
        return logic.allowance(owner, spender);
    }
    function triggerTransfer(address src, address dst, uint256 wad) logicOnly {
        Transfer(src, dst, wad);
    }
    function setLogic(address logic_) public logicOnly {
        assert(logic_ != address(0));
        logic = TokenLogicI(logic_);
        LogLogicReplaced(logic);
    }
    function transfer(address dst, uint256 wad) public stoppable returns (bool) {
        bool retVal = logic.transfer(msg.sender, dst, wad);
        if (retVal) {
            uint codeLength;
            assembly {
                codeLength := extcodesize(dst)
            }
            if (codeLength>0) {
                ERC223ReceivingContract receiver = ERC223ReceivingContract(dst);
                bytes memory empty;
                receiver.tokenFallback(msg.sender, wad, empty);
            }
            Transfer(msg.sender, dst, wad);
        }
        return retVal;
    }
    function transferFrom(address src, address dst, uint256 wad) public stoppable returns (bool) {
        bool retVal = logic.transferFrom(src, dst, wad);
        if (retVal) {
            uint codeLength;
            assembly {
                codeLength := extcodesize(dst)
            }
            if (codeLength>0) {
                ERC223ReceivingContract receiver = ERC223ReceivingContract(dst);
                bytes memory empty;
                receiver.tokenFallback(src, wad, empty);
            }
            Transfer(src, dst, wad);
        }
        return retVal;
    }
    function approve(address guy, uint256 wad) public stoppable returns (bool) {
        bool ok = logic.approve(msg.sender, guy, wad);
        if (ok)
            Approval(msg.sender, guy, wad);
        return ok;
    }
    function pull(address src, uint256 wad) public stoppable returns (bool) {
        return transferFrom(src, msg.sender, wad);
    }
    function mintFor(address recipient, uint256 wad) public stoppable onlyRole("minter") {
        logic.mintFor(recipient, wad);
        LogMint(recipient, wad);
        Transfer(address(0x0), recipient, wad);
    }
    function burn(uint256 wad) public stoppable {
        logic.burn(msg.sender, wad);
        LogBurn(msg.sender, wad);
    }
    function setName(string name_) public roleOrOwner("admin") {
        name = name_;
    }
}
