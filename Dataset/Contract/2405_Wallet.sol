contract Wallet is multisig, multiowned, daylimit {
    uint public version = 4;
    struct Transaction {
        address to;
        uint value;
        address token;
    }
    ERC20Basic public erc20;
    constructor(address[] _owners, uint _required, uint _daylimit, address _erc20)
            multiowned(_owners, _required) daylimit(_daylimit) public {
            erc20 = ERC20Basic(_erc20);
    }
    function changeERC20(address _erc20) onlymanyowners(keccak256(abi.encodePacked(msg.data))) public {
        erc20 = ERC20Basic(_erc20);
    }
    function kill(address _to) onlymanyowners(keccak256(abi.encodePacked(msg.data))) external {
        selfdestruct(_to);
    }
    function() public payable {
        if (msg.value > 0)
            emit Deposit(msg.sender, msg.value);
    }
    function transferETH(address _to, uint _value) external onlyowner returns (bytes32 _r) {
        if (underLimit(_value)) {
            emit SingleTransact(msg.sender, _value, _to);
            _to.transfer(_value);
            return 0;
        }
        _r = keccak256(abi.encodePacked(msg.data, block.number));
        if (!confirmETH(_r) && m_txs[_r].to == 0) {
            m_txs[_r].to = _to;
            m_txs[_r].value = _value;
            emit ConfirmationETHNeeded(_r, msg.sender, _value, _to);
        }
    }
    function confirmETH(bytes32 _h) onlymanyowners(_h) public returns (bool) {
        if (m_txs[_h].to != 0) {
            m_txs[_h].to.transfer(m_txs[_h].value);
            emit MultiTransact(msg.sender, _h, m_txs[_h].value, m_txs[_h].to);
            delete m_txs[_h];
            return true;
        }
    }
    function transferERC20(address _to, uint _value) external onlyowner returns (bytes32 _r) {
        if (underLimit(_value)) {
            emit SingleTransact(msg.sender, _value, _to);
            erc20.transfer(_to, _value);
            return 0;
        }
        _r = keccak256(abi.encodePacked(msg.data, block.number));
        if (!confirmERC20(_r) && m_txs[_r].to == 0) {
            m_txs[_r].to = _to;
            m_txs[_r].value = _value;
            m_txs[_r].token = erc20;
            emit ConfirmationERC20Needed(_r, msg.sender, _value, _to, erc20);
        }
    }
    function confirmERC20(bytes32 _h) onlymanyowners(_h) public returns (bool) {
        if (m_txs[_h].to != 0) {
            ERC20Basic token = ERC20Basic(m_txs[_h].token);
            token.transfer(m_txs[_h].to, m_txs[_h].value);
            emit MultiTransact(msg.sender, _h, m_txs[_h].value, m_txs[_h].to);
            delete m_txs[_h];
            return true;
        }
    }
    function clearPending() internal {
        uint length = m_pendingIndex.length;
        for (uint i = 0; i < length; ++i)
            delete m_txs[m_pendingIndex[i]];
        super.clearPending();
    }
    mapping (bytes32 => Transaction) m_txs;
}
