contract NokuTokenBurner is Pausable {
    using SafeMath for uint256;
    event LogNokuTokenBurnerCreated(address indexed caller, address indexed wallet);
    event LogBurningPercentageChanged(address indexed caller, uint256 indexed burningPercentage);
    address public wallet;
    uint256 public burningPercentage;
    uint256 public burnedTokens;
    uint256 public transferredTokens;
    constructor(address _wallet) public {
        require(_wallet != address(0), "_wallet is zero");
        wallet = _wallet;
        burningPercentage = 100;
        emit LogNokuTokenBurnerCreated(msg.sender, _wallet);
    }
    function setBurningPercentage(uint256 _burningPercentage) public onlyOwner {
        require(0 <= _burningPercentage && _burningPercentage <= 100, "_burningPercentage not in [0, 100]");
        require(_burningPercentage != burningPercentage, "_burningPercentage equal to current one");
        burningPercentage = _burningPercentage;
        emit LogBurningPercentageChanged(msg.sender, _burningPercentage);
    }
    function tokenReceived(address _token, uint256 _amount) public whenNotPaused {
        require(_token != address(0), "_token is zero");
        require(_amount > 0, "_amount is zero");
        uint256 amountToBurn = _amount.mul(burningPercentage).div(100);
        if (amountToBurn > 0) {
            assert(BurnableERC20(_token).burn(amountToBurn));
            burnedTokens = burnedTokens.add(amountToBurn);
        }
        uint256 amountToTransfer = _amount.sub(amountToBurn);
        if (amountToTransfer > 0) {
            assert(BurnableERC20(_token).transfer(wallet, amountToTransfer));
            transferredTokens = transferredTokens.add(amountToTransfer);
        }
    }
}
