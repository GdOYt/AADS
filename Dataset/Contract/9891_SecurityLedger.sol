contract SecurityLedger is Ownable {
    using SafeMath for uint256;
    struct TokenLot {
        uint amount;
        uint purchaseDate;
        bool restricted;
    }
    mapping(address => TokenLot[]) public tokenLotsOf;
    SecurityController public controller;
    mapping(address => uint) public balanceOf;
    mapping (address => mapping (address => uint)) public allowance;
    uint public totalSupply;
    uint public mintingNonce;
    bool public mintingStopped;
    constructor() public {
    }
    function setController(address _controller) public onlyOwner {
        controller = SecurityController(_controller);
    }
    function stopMinting() public onlyOwner {
        mintingStopped = true;
    }
    function mint(address addr, uint value, uint timestamp) public onlyOwner {
        require(!mintingStopped);
        uint time = timestamp;
        if(time == 0) {
            time = block.timestamp;
        }
        balanceOf[addr] = balanceOf[addr].add(value);
        tokenLotsOf[addr].push(TokenLot(value, time, true));
        controller.ledgerTransfer(0, addr, value);
        totalSupply = totalSupply.add(value);
    }
    function multiMint(uint nonce, uint256[] bits, uint timestamp) external onlyOwner {
        require(!mintingStopped);
        if (nonce != mintingNonce) return;
        mintingNonce = mintingNonce.add(1);
        uint256 lomask = (1 << 96) - 1;
        uint created = 0;
        uint time = timestamp;
        if(time == 0) {
            time = block.timestamp;
        }
        for (uint i = 0; i < bits.length; i++) {
            address addr = address(bits[i]>>96);
            uint value = bits[i] & lomask;
            balanceOf[addr] = balanceOf[addr].add(value);
            tokenLotsOf[addr].push(TokenLot(value, time, true));
            controller.ledgerTransfer(0, addr, value);
            created = created.add(value);
        }
        totalSupply = totalSupply.add(created);
    }
    function sendReceivedTokens(address token, address sender, uint amount) public onlyOwner {
        ERC20Basic t = ERC20Basic(token);
        require(t.transfer(sender, amount));
    }
    modifier onlyController() {
        require(msg.sender == address(controller));
        _;
    }
    function walkTokenLots(address from, address to, uint amount, uint lockoutTime, bool removeTokens,
        bool newTokensAreRestricted, bool preservePurchaseDate)
        internal returns (uint numTransferrableTokens)
    {
        TokenLot[] storage fromTokenLots = tokenLotsOf[from];
        for(uint i=0; i<fromTokenLots.length; i++) {
            TokenLot storage lot = fromTokenLots[i];
            uint lotAmount = lot.amount;
            if(lotAmount == 0) {
                continue;
            }
            if(lockoutTime > 0) {
                if(lot.restricted && lot.purchaseDate > lockoutTime) {
                    continue;
                }
            }
            uint remaining = amount - numTransferrableTokens;
            if(lotAmount >= remaining) {
                numTransferrableTokens = numTransferrableTokens.add(remaining);
                if(removeTokens) {
                    lot.amount = lotAmount.sub(remaining);
                    if(to != address(0)) {
                        if(preservePurchaseDate) {
                            tokenLotsOf[to].push(TokenLot(remaining, lot.purchaseDate, newTokensAreRestricted));
                        }
                        else {
                            tokenLotsOf[to].push(TokenLot(remaining, block.timestamp, newTokensAreRestricted));
                        }
                    }
                }
                break;
            }
            numTransferrableTokens = numTransferrableTokens.add(lotAmount);
            if(removeTokens) {
                lot.amount = 0;
                if(to != address(0)) {
                    if(preservePurchaseDate) {
                        tokenLotsOf[to].push(TokenLot(lotAmount, lot.purchaseDate, newTokensAreRestricted));
                    }
                    else {
                        tokenLotsOf[to].push(TokenLot(lotAmount, block.timestamp, newTokensAreRestricted));
                    }
                }
            }
        }
    }
    function transferDryRun(address from, address to, uint amount, uint lockoutTime) public onlyController returns (uint) {
        return walkTokenLots(from, to, amount, lockoutTime, false, false, false);
    }
    function transfer(address _from, address _to, uint _value, uint lockoutTime, bool newTokensAreRestricted, bool preservePurchaseDate) public onlyController returns (bool success) {
        if (balanceOf[_from] < _value) return false;
        uint tokensTransferred = walkTokenLots(_from, _to, _value, lockoutTime, true, newTokensAreRestricted, preservePurchaseDate);
        require(tokensTransferred == _value);
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        return true;
    }
    function transferFrom(address _spender, address _from, address _to, uint _value, uint lockoutTime, bool newTokensAreRestricted, bool preservePurchaseDate) public onlyController returns (bool success) {
        if (balanceOf[_from] < _value) return false;
        uint allowed = allowance[_from][_spender];
        if (allowed < _value) return false;
        uint tokensTransferred = walkTokenLots(_from, _to, _value, lockoutTime, true, newTokensAreRestricted, preservePurchaseDate);
        require(tokensTransferred == _value);
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        allowance[_from][_spender] = allowed.sub(_value);
        return true;
    }
    function approve(address _owner, address _spender, uint _value) public onlyController returns (bool success) {
        if ((_value != 0) && (allowance[_owner][_spender] != 0)) {
            return false;
        }
        allowance[_owner][_spender] = _value;
        return true;
    }
    function increaseApproval (address _owner, address _spender, uint _addedValue) public onlyController returns (bool success) {
        uint oldValue = allowance[_owner][_spender];
        allowance[_owner][_spender] = oldValue.add(_addedValue);
        return true;
    }
    function decreaseApproval (address _owner, address _spender, uint _subtractedValue) public onlyController returns (bool success) {
        uint oldValue = allowance[_owner][_spender];
        if (_subtractedValue > oldValue) {
            allowance[_owner][_spender] = 0;
        } else {
            allowance[_owner][_spender] = oldValue.sub(_subtractedValue);
        }
        return true;
    }
    function burn(address _owner, uint _amount) public onlyController {
        require(balanceOf[_owner] >= _amount);
        balanceOf[_owner] = balanceOf[_owner].sub(_amount);
        walkTokenLots(_owner, address(0), _amount, 0, true, false, false);
        totalSupply = totalSupply.sub(_amount);
    }
}
