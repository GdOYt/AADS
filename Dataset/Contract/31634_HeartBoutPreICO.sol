contract HeartBoutPreICO is CappedCrowdsale, Ownable {
    using SafeMath for uint256;
    address public token;
    uint256 public minCount;
    mapping(string => address) bindAccountsAddress;
    mapping(address => string) bindAddressAccounts;
    string[] accounts;
    event GetBindTokensAccountEvent(address _address, string _account);
    function HeartBoutPreICO(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet, uint256 _cap, uint256 _minCount) public
    CappedCrowdsale(_startTime, _endTime, _rate, _wallet, _cap)
    {
        token = 0x00305cB299cc82a8A74f8da00AFA6453741d9a15Ed;
        minCount = _minCount;
    }
    function () payable public {
    }
    function buyTokens(string _account) public payable {
        require(!stringEqual(_account, ""));
        require(validPurchase());
        require(msg.value >= minCount);
        if(!stringEqual(bindAddressAccounts[msg.sender], "")) {
            require(stringEqual(bindAddressAccounts[msg.sender], _account));
        }
        uint256 weiAmount = msg.value;
        uint256 tokens = weiAmount.mul(rate);
        require(token.call(bytes4(keccak256("mint(address,uint256)")), msg.sender, tokens));
        bindAccountsAddress[_account] = msg.sender;
        bindAddressAccounts[msg.sender] = _account;
        accounts.push(_account);
        weiRaised = weiRaised.add(weiAmount);
        forwardFunds();
    }
    function getEachBindAddressAccount() onlyOwner public {
        for (uint i = 0; i < accounts.length; i++) {
            GetBindTokensAccountEvent(bindAccountsAddress[accounts[i]], accounts[i]);
        }
    }
    function getBindAccountAddress(string _account) public constant returns (address) {
        return bindAccountsAddress[_account];
    }
    function getBindAddressAccount(address _accountAddress) public constant returns (string) {
        return bindAddressAccounts[_accountAddress];
    }
    function forwardFunds() internal {
        wallet.transfer(msg.value);
    }
    function stringEqual(string _a, string _b) internal pure returns (bool) {
        return keccak256(_a) == keccak256(_b);
    }
    function changeWallet(address _wallet) onlyOwner public {
        wallet = _wallet;
    }
    function removeContract() onlyOwner public {
        selfdestruct(wallet);
    }
}
