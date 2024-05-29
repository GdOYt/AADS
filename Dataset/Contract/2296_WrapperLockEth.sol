contract WrapperLockEth is BasicToken, Ownable {
    using SafeMath for uint256;
    address public TRANSFER_PROXY;
    mapping (address => bool) public isSigner;
    string public name;
    string public symbol;
    uint public decimals;
    address public originalToken = 0x00;
    mapping (address => uint) public depositLock;
    mapping (address => uint256) public balances;
    function WrapperLockEth(string _name, string _symbol, uint _decimals, address _transferProxy) Ownable() {
        TRANSFER_PROXY = _transferProxy;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        isSigner[msg.sender] = true;
    }
    function deposit(uint _value, uint _forTime) public payable returns (bool success) {
        require(_forTime >= 1);
        require(now + _forTime * 1 hours >= depositLock[msg.sender]);
        balances[msg.sender] = balances[msg.sender].add(msg.value);
        totalSupply_ = totalSupply_.add(msg.value);
        depositLock[msg.sender] = now + _forTime * 1 hours;
        return true;
    }
    function withdraw(
        uint _value,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint signatureValidUntilBlock
    )
        public
        returns
        (bool)
    {
        require(balanceOf(msg.sender) >= _value);
        if (now > depositLock[msg.sender]) {
            balances[msg.sender] = balances[msg.sender].sub(_value);
            totalSupply_ = totalSupply_.sub(msg.value);
            msg.sender.transfer(_value);
        } else {
            require(block.number < signatureValidUntilBlock);
            require(isValidSignature(keccak256(msg.sender, address(this), signatureValidUntilBlock), v, r, s));
            balances[msg.sender] = balances[msg.sender].sub(_value);
            totalSupply_ = totalSupply_.sub(msg.value);
            depositLock[msg.sender] = 0;
            msg.sender.transfer(_value);
        }
        return true;
    }
    function withdrawDifferentToken(address _token, bool _erc20old) public onlyOwner returns (bool) {
        require(ERC20(_token).balanceOf(address(this)) > 0);
        if (_erc20old) {
            ERC20Old(_token).transfer(msg.sender, ERC20(_token).balanceOf(address(this)));
        } else {
            ERC20(_token).transfer(msg.sender, ERC20(_token).balanceOf(address(this)));
        }
        return true;
    }
    function transfer(address _to, uint256 _value) public returns (bool) {
        return false;
    }
    function transferFrom(address _from, address _to, uint _value) public {
        require(isSigner[_to] || isSigner[_from]);
        assert(msg.sender == TRANSFER_PROXY);
        balances[_to] = balances[_to].add(_value);
        depositLock[_to] = depositLock[_to] > now ? depositLock[_to] : now + 1 hours;
        balances[_from] = balances[_from].sub(_value);
        Transfer(_from, _to, _value);
    }
    function allowance(address _owner, address _spender) public constant returns (uint) {
        if (_spender == TRANSFER_PROXY) {
            return 2**256 - 1;
        }
    }
    function balanceOf(address _owner) public constant returns (uint256) {
        return balances[_owner];
    }
    function isValidSignature(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s)
        public
        constant
        returns (bool)
    {
        return isSigner[ecrecover(
            keccak256("\x19Ethereum Signed Message:\n32", hash),
            v,
            r,
            s
        )];
    }
    function addSigner(address _newSigner) public {
        require(isSigner[msg.sender]);
        isSigner[_newSigner] = true;
    }
    function keccak(address _sender, address _wrapper, uint _validTill) public constant returns(bytes32) {
        return keccak256(_sender, _wrapper, _validTill);
    }
}
