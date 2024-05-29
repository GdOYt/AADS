contract SecurityController is ISecurityController, Ownable {
    ISecurityLedger public ledger;
    ISecurityToken public token;
    ISecuritySale public sale;
    IInvestorList public investorList;
    ITransferAuthorizations public transferAuthorizations;
    IAffiliateList public affiliateList;
    uint public lockoutPeriod = 10 * 60 * 60;  
    mapping(address => bool) public transferAuthPermission;
    constructor() public {
    }
    function setTransferAuthorized(address from, address to, uint expiry) public {
        require(transferAuthPermission[msg.sender]);
        require(from != 0);
        if(expiry > 0) {
            require(expiry > block.timestamp);
            require(expiry <= (block.timestamp + 30 days));
        }
        transferAuthorizations.set(from, to, expiry);
    }
    function setLockoutPeriod(uint _lockoutPeriod) public onlyOwner {
        lockoutPeriod = _lockoutPeriod;
    }
    function setToken(address _token) public onlyOwner {
        token = ISecurityToken(_token);
    }
    function setLedger(address _ledger) public onlyOwner {
        ledger = ISecurityLedger(_ledger);
    }
    function setSale(address _sale) public onlyOwner {
        sale = ISecuritySale(_sale);
    }
    function setInvestorList(address _investorList) public onlyOwner {
        investorList = IInvestorList(_investorList);
    }
    function setTransferAuthorizations(address _transferAuthorizations) public onlyOwner {
        transferAuthorizations = ITransferAuthorizations(_transferAuthorizations);
    }
    function setAffiliateList(address _affiliateList) public onlyOwner {
        affiliateList = IAffiliateList(_affiliateList);
    }
    function setDependencies(address _token, address _ledger, address _sale,
        address _investorList, address _transferAuthorizations, address _affiliateList)
        public onlyOwner
    {
        token = ISecurityToken(_token);
        ledger = ISecurityLedger(_ledger);
        sale = ISecuritySale(_sale);
        investorList = IInvestorList(_investorList);
        transferAuthorizations = ITransferAuthorizations(_transferAuthorizations);
        affiliateList = IAffiliateList(_affiliateList);
    }
    function setTransferAuthPermission(address agent, bool hasPermission) public onlyOwner {
        require(agent != address(0));
        transferAuthPermission[agent] = hasPermission;
    }
    modifier onlyToken() {
        require(msg.sender == address(token));
        _;
    }
    modifier onlyLedger() {
        require(msg.sender == address(ledger));
        _;
    }
    function totalSupply() public view returns (uint) {
        return ledger.totalSupply();
    }
    function balanceOf(address _a) public view returns (uint) {
        return ledger.balanceOf(_a);
    }
    function allowance(address _owner, address _spender) public view returns (uint) {
        return ledger.allowance(_owner, _spender);
    }
    function isTransferAuthorized(address _from, address _to) public view returns (bool) {
        uint expiry = transferAuthorizations.get(_from, _to);
        uint globalExpiry = transferAuthorizations.get(_from, 0);
        if(globalExpiry > expiry) {
            expiry = globalExpiry;
        }
        return expiry > block.timestamp;
    }
    function checkTransfer(address _from, address _to, uint _value, uint lockoutTime)
        public
        returns (bool canTransfer, bool useLockoutTime, bool newTokensAreRestricted, bool preservePurchaseDate) {
        preservePurchaseDate = false;
        bool transferIsAuthorized = isTransferAuthorized(_from, _to);
        bool fromIsAffiliate = affiliateList.inListAsOf(_from, block.timestamp);
        bool toIsAffiliate = affiliateList.inListAsOf(_to, block.timestamp);
        if(transferIsAuthorized) {
            canTransfer = true;
            if(fromIsAffiliate || toIsAffiliate) {
                newTokensAreRestricted = true;
            }
        }
        else if(!fromIsAffiliate) {
            if(investorList.hasRole(_from, investorList.ROLE_REGS())
                && investorList.hasRole(_to, investorList.ROLE_REGS())) {
                canTransfer = true;
            }
            else {
                if(ledger.transferDryRun(_from, _to, _value, lockoutTime) == _value) {
                    canTransfer = true;
                    useLockoutTime = true;
                }
            }
        }
    }
    function ledgerTransfer(address from, address to, uint val) public onlyLedger {
        token.controllerTransfer(from, to, val);
    }
    function transfer(address _from, address _to, uint _value) public onlyToken returns (bool success) {
        uint lockoutTime = block.timestamp - lockoutPeriod;
        bool canTransfer;
        bool useLockoutTime;
        bool newTokensAreRestricted;
        bool preservePurchaseDate;
        (canTransfer, useLockoutTime, newTokensAreRestricted, preservePurchaseDate)
            = checkTransfer(_from, _to, _value, lockoutTime);
        if(!canTransfer) {
            return false;
        }
        uint overrideLockoutTime = lockoutTime;
        if(!useLockoutTime) {
            overrideLockoutTime = 0;
        }
        return ledger.transfer(_from, _to, _value, overrideLockoutTime, newTokensAreRestricted, preservePurchaseDate);
    }
    function transferFrom(address _spender, address _from, address _to, uint _value) public onlyToken returns (bool success) {
        uint lockoutTime = block.timestamp - lockoutPeriod;
        bool canTransfer;
        bool useLockoutTime;
        bool newTokensAreRestricted;
        bool preservePurchaseDate;
        (canTransfer, useLockoutTime, newTokensAreRestricted, preservePurchaseDate)
            = checkTransfer(_from, _to, _value, lockoutTime);
        if(!canTransfer) {
            return false;
        }
        uint overrideLockoutTime = lockoutTime;
        if(!useLockoutTime) {
            overrideLockoutTime = 0;
        }
        return ledger.transferFrom(_spender, _from, _to, _value, overrideLockoutTime, newTokensAreRestricted, preservePurchaseDate);
    }
    function approve(address _owner, address _spender, uint _value) public onlyToken returns (bool success) {
        return ledger.approve(_owner, _spender, _value);
    }
    function increaseApproval (address _owner, address _spender, uint _addedValue) public onlyToken returns (bool success) {
        return ledger.increaseApproval(_owner, _spender, _addedValue);
    }
    function decreaseApproval (address _owner, address _spender, uint _subtractedValue) public onlyToken returns (bool success) {
        return ledger.decreaseApproval(_owner, _spender, _subtractedValue);
    }
    function burn(address _owner, uint _amount) public onlyToken {
        ledger.burn(_owner, _amount);
    }
}
