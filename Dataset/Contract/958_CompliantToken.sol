contract CompliantToken is Validator, DetailedERC20, MintableToken {
    Whitelist public whiteListingContract;
    struct TransactionStruct {
        address from;
        address to;
        uint256 value;
        uint256 fee;
        address spender;
    }
    mapping (uint => TransactionStruct) public pendingTransactions;
    mapping (address => mapping (address => uint256)) public pendingApprovalAmount;
    uint256 public currentNonce = 0;
    uint256 public transferFee;
    address public feeRecipient;
    modifier checkIsInvestorApproved(address _account) {
        require(whiteListingContract.isInvestorApproved(_account));
        _;
    }
    modifier checkIsAddressValid(address _account) {
        require(_account != address(0));
        _;
    }
    modifier checkIsValueValid(uint256 _value) {
        require(_value > 0);
        _;
    }
    event TransferRejected(
        address indexed from,
        address indexed to,
        uint256 value,
        uint256 indexed nonce,
        uint256 reason
    );
    event TransferWithFee(
        address indexed from,
        address indexed to,
        uint256 value,
        uint256 fee
    );
    event RecordedPendingTransaction(
        address indexed from,
        address indexed to,
        uint256 value,
        uint256 fee,
        address indexed spender,
        uint256 nonce
    );
    event WhiteListingContractSet(address indexed _whiteListingContract);
    event FeeSet(uint256 indexed previousFee, uint256 indexed newFee);
    event FeeRecipientSet(address indexed previousRecipient, address indexed newRecipient);
    constructor(
        address _owner,
        string _name, 
        string _symbol, 
        uint8 _decimals,
        address whitelistAddress,
        address recipient,
        uint256 fee
    )
        public
        MintableToken(_owner)
        DetailedERC20(_name, _symbol, _decimals)
        Validator()
    {
        setWhitelistContract(whitelistAddress);
        setFeeRecipient(recipient);
        setFee(fee);
    }
    function setWhitelistContract(address whitelistAddress)
        public
        onlyValidator
        checkIsAddressValid(whitelistAddress)
    {
        whiteListingContract = Whitelist(whitelistAddress);
        emit WhiteListingContractSet(whiteListingContract);
    }
    function setFee(uint256 fee)
        public
        onlyValidator
    {
        emit FeeSet(transferFee, fee);
        transferFee = fee;
    }
    function setFeeRecipient(address recipient)
        public
        onlyValidator
        checkIsAddressValid(recipient)
    {
        emit FeeRecipientSet(feeRecipient, recipient);
        feeRecipient = recipient;
    }
    function updateName(string _name) public onlyOwner {
        require(bytes(_name).length != 0);
        name = _name;
    }
    function updateSymbol(string _symbol) public onlyOwner {
        require(bytes(_symbol).length != 0);
        symbol = _symbol;
    }
    function transfer(address _to, uint256 _value)
        public
        checkIsInvestorApproved(msg.sender)
        checkIsInvestorApproved(_to)
        checkIsValueValid(_value)
        returns (bool)
    {
        uint256 pendingAmount = pendingApprovalAmount[msg.sender][address(0)];
        if (msg.sender == feeRecipient) {
            require(_value.add(pendingAmount) <= balances[msg.sender]);
            pendingApprovalAmount[msg.sender][address(0)] = pendingAmount.add(_value);
        } else {
            require(_value.add(pendingAmount).add(transferFee) <= balances[msg.sender]);
            pendingApprovalAmount[msg.sender][address(0)] = pendingAmount.add(_value).add(transferFee);
        }
        pendingTransactions[currentNonce] = TransactionStruct(
            msg.sender,
            _to,
            _value,
            transferFee,
            address(0)
        );
        emit RecordedPendingTransaction(msg.sender, _to, _value, transferFee, address(0), currentNonce);
        currentNonce++;
        return true;
    }
    function transferFrom(address _from, address _to, uint256 _value)
        public 
        checkIsInvestorApproved(_from)
        checkIsInvestorApproved(_to)
        checkIsValueValid(_value)
        returns (bool)
    {
        uint256 allowedTransferAmount = allowed[_from][msg.sender];
        uint256 pendingAmount = pendingApprovalAmount[_from][msg.sender];
        if (_from == feeRecipient) {
            require(_value.add(pendingAmount) <= balances[_from]);
            require(_value.add(pendingAmount) <= allowedTransferAmount);
            pendingApprovalAmount[_from][msg.sender] = pendingAmount.add(_value);
        } else {
            require(_value.add(pendingAmount).add(transferFee) <= balances[_from]);
            require(_value.add(pendingAmount).add(transferFee) <= allowedTransferAmount);
            pendingApprovalAmount[_from][msg.sender] = pendingAmount.add(_value).add(transferFee);
        }
        pendingTransactions[currentNonce] = TransactionStruct(
            _from,
            _to,
            _value,
            transferFee,
            msg.sender
        );
        emit RecordedPendingTransaction(_from, _to, _value, transferFee, msg.sender, currentNonce);
        currentNonce++;
        return true;
    }
    function approveTransfer(uint256 nonce)
        external 
        onlyValidator 
        checkIsInvestorApproved(pendingTransactions[nonce].from)
        checkIsInvestorApproved(pendingTransactions[nonce].to)
        checkIsValueValid(pendingTransactions[nonce].value)
        returns (bool)
    {   
        address from = pendingTransactions[nonce].from;
        address spender = pendingTransactions[nonce].spender;
        address to = pendingTransactions[nonce].to;
        uint256 value = pendingTransactions[nonce].value;
        uint256 allowedTransferAmount = allowed[from][spender];
        uint256 pendingAmount = pendingApprovalAmount[from][spender];
        uint256 fee = pendingTransactions[nonce].fee;
        uint256 balanceFrom = balances[from];
        uint256 balanceTo = balances[to];
        delete pendingTransactions[nonce];
        if (from == feeRecipient) {
            fee = 0;
            balanceFrom = balanceFrom.sub(value);
            balanceTo = balanceTo.add(value);
            if (spender != address(0)) {
                allowedTransferAmount = allowedTransferAmount.sub(value);
            } 
            pendingAmount = pendingAmount.sub(value);
        } else {
            balanceFrom = balanceFrom.sub(value.add(fee));
            balanceTo = balanceTo.add(value);
            balances[feeRecipient] = balances[feeRecipient].add(fee);
            if (spender != address(0)) {
                allowedTransferAmount = allowedTransferAmount.sub(value).sub(fee);
            }
            pendingAmount = pendingAmount.sub(value).sub(fee);
        }
        emit TransferWithFee(
            from,
            to,
            value,
            fee
        );
        emit Transfer(
            from,
            to,
            value
        );
        balances[from] = balanceFrom;
        balances[to] = balanceTo;
        allowed[from][spender] = allowedTransferAmount;
        pendingApprovalAmount[from][spender] = pendingAmount;
        return true;
    }
    function rejectTransfer(uint256 nonce, uint256 reason)
        external 
        onlyValidator
        checkIsAddressValid(pendingTransactions[nonce].from)
    {        
        address from = pendingTransactions[nonce].from;
        address spender = pendingTransactions[nonce].spender;
        if (from == feeRecipient) {
            pendingApprovalAmount[from][spender] = pendingApprovalAmount[from][spender]
                .sub(pendingTransactions[nonce].value);
        } else {
            pendingApprovalAmount[from][spender] = pendingApprovalAmount[from][spender]
                .sub(pendingTransactions[nonce].value).sub(pendingTransactions[nonce].fee);
        }
        emit TransferRejected(
            from,
            pendingTransactions[nonce].to,
            pendingTransactions[nonce].value,
            nonce,
            reason
        );
        delete pendingTransactions[nonce];
    }
}
