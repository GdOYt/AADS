contract nix is Ownable, StandardToken {
    string public constant symbol =  "NIX";
    string public constantname =  "NIX";
    uint256 public constant decimals = 18;
    uint256 reserveTokensLockTime;
    address reserveTokenAddress;
    address public depositWalletAddress;
    uint256 public weiRaised;
    using SafeMath for uint256;
    constructor() public {
        owner = msg.sender;
        depositWalletAddress = owner;
        totalSupply_ = 500000000 ether;  
        balances[owner] = 150000000 ether;
        emit Transfer(address(0),owner, balances[owner]);
        reserveTokensLockTime = 182 days;  
        reserveTokenAddress = 0xf6c5dE9E1a6b36ABA36c6E6e86d500BcBA9CeC96;  
        balances[reserveTokenAddress] = 350000000 ether;
        emit Transfer(address(0),reserveTokenAddress, balances[reserveTokenAddress]);
    }
    event Buy(address _from, uint256 _ethInWei, string userId);
    function buy(string userId)public payable {
        require(msg.value > 0);
        require(msg.sender != address(0));
        weiRaised += msg.value;
        forwardFunds();
        emit Buy(msg.sender, msg.value, userId);
    }  
    function forwardFunds()internal {
        depositWalletAddress.transfer(msg.value);
    }
    function changeDepositWalletAddress(address newDepositWalletAddr)public onlyOwner {
        require(newDepositWalletAddr != 0);
        depositWalletAddress = newDepositWalletAddr;
    }
    function transfer(address _to, uint256 _value) public reserveTokenLock returns (bool) {
        super.transfer(_to,_value);
    }
    function transferFrom(address _from, address _to, uint256 _value) public reserveTokenLock returns (bool){
        super.transferFrom(_from, _to, _value);
    }
    function approve(address _spender, uint256 _value) public reserveTokenLock returns (bool) {
        super.approve(_spender, _value);
    }
    function increaseApproval(address _spender, uint _addedValue) public reserveTokenLock returns (bool) {
        super.increaseApproval(_spender, _addedValue);
    }
    modifier reserveTokenLock () {
        if(msg.sender == reserveTokenAddress){
            require(block.timestamp > reserveTokensLockTime);
            _;
        }
        else{
            _;
        }
    }
}
