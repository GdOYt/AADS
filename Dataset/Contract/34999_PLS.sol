contract PLS is DSToken("PLS"), Controlled {
    function PLS() {
        setName("DACPLAY Token");
    }
    function transferFrom(address _from, address _to, uint256 _amount
    ) returns (bool success) {
        if (isContract(controller)) {
            if (!TokenController(controller).onTransfer(_from, _to, _amount))
               throw;
        }
        success = super.transferFrom(_from, _to, _amount);
        if (success && isContract(_to))
        {
            if(!_to.call(bytes4(bytes32(keccak256("receiveToken(address,uint256,address)"))), _from, _amount, this)) {
            }
        }
    }
    function transfer(
        address _to,
        uint256 _value,
        bytes _data)
        public
        returns (bool)
    {
        require(transfer(_to, _value));
        if (isContract(_to)) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }
        return true;
    }
    function approve(address _spender, uint256 _amount) returns (bool success) {
        if (isContract(controller)) {
            if (!TokenController(controller).onApprove(msg.sender, _spender, _amount))
                throw;
        }
        return super.approve(_spender, _amount);
    }
    function mint(address _guy, uint _wad) auth stoppable {
        super.mint(_guy, _wad);
        Transfer(0, _guy, _wad);
    }
    function burn(address _guy, uint _wad) auth stoppable {
        super.burn(_guy, _wad);
        Transfer(_guy, 0, _wad);
    }
    function approveAndCall(address _spender, uint256 _amount, bytes _extraData
    ) returns (bool success) {
        if (!approve(_spender, _amount)) throw;
        ApproveAndCallFallBack(_spender).receiveApproval(
            msg.sender,
            _amount,
            this,
            _extraData
        );
        return true;
    }
    function isContract(address _addr) constant internal returns(bool) {
        uint size;
        if (_addr == 0) return false;
        assembly {
            size := extcodesize(_addr)
        }
        return size>0;
    }
    function ()  payable {
        if (isContract(controller)) {
            if (! TokenController(controller).proxyPayment.value(msg.value)(msg.sender))
                throw;
        } else {
            throw;
        }
    }
    function claimTokens(address _token) onlyController {
        if (_token == 0x0) {
            controller.transfer(this.balance);
            return;
        }
        ERC20 token = ERC20(_token);
        uint balance = token.balanceOf(this);
        token.transfer(controller, balance);
        ClaimedTokens(_token, controller, balance);
    }
    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
}
