contract GigToken is MintingERC20 {
    SellableToken public crowdSale;  
    SellableToken public privateSale;
    bool public transferFrozen = false;
    uint256 public crowdSaleEndTime;
    mapping(address => uint256) public lockedBalancesReleasedAfterOneYear;
    modifier onlyCrowdSale() {
        require(crowdSale != address(0) && msg.sender == address(crowdSale));
        _;
    }
    modifier onlySales() {
        require((privateSale != address(0) && msg.sender == address(privateSale)) ||
            (crowdSale != address(0) && msg.sender == address(crowdSale)));
        _;
    }
    event MaxSupplyBurned(uint256 burnedTokens);
    function GigToken(bool _locked) public
        MintingERC20(0, maxSupply, 'GigBit', 18, 'GBTC', false, _locked)
    {
        standard = 'GBTC 0.1';
        maxSupply = uint256(1000000000).mul(uint256(10) ** decimals);
    }
    function setCrowdSale(address _crowdSale) public onlyOwner {
        require(_crowdSale != address(0));
        crowdSale = SellableToken(_crowdSale);
        crowdSaleEndTime = crowdSale.endTime();
    }
    function setPrivateSale(address _privateSale) public onlyOwner {
        require(_privateSale != address(0));
        privateSale = SellableToken(_privateSale);
    }
    function freezing(bool _transferFrozen) public onlyOwner {
        transferFrozen = _transferFrozen;
    }
    function isTransferAllowed(address _from, uint256 _value) public view returns (bool status) {
        uint256 senderBalance = balanceOf(_from);
        if (transferFrozen == true || senderBalance < _value) {
            return false;
        }
        uint256 lockedBalance = lockedBalancesReleasedAfterOneYear[_from];
    if (lockedBalance > 0 && senderBalance.sub(_value) < lockedBalance) {
            uint256 unlockTime = crowdSaleEndTime + 1 years;
            if (crowdSaleEndTime == 0 || block.timestamp < unlockTime) {
                return false;
            }
            uint256 secsFromUnlock = block.timestamp.sub(unlockTime);
            uint256 months = secsFromUnlock / 30 days;
            if (months > 12) {
                months = 12;
            }
            uint256 tokensPerMonth = lockedBalance / 12;
            uint256 unlockedBalance = tokensPerMonth.mul(months);
            uint256 actualLockedBalance = lockedBalance.sub(unlockedBalance);
            if (senderBalance.sub(_value) < actualLockedBalance) {
                return false;
            }
        }
        if (block.timestamp < crowdSaleEndTime &&
            crowdSale != address(0) &&
            crowdSale.isTransferAllowed(_from, _value) == false
        ) {
            return false;
        }
        return true;
    }
    function transfer(address _to, uint _value) public returns (bool) {
        require(isTransferAllowed(msg.sender, _value));
        return super.transfer(_to, _value);
    }
    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        require((crowdSaleEndTime <= block.timestamp) && isTransferAllowed(_from, _value));
        return super.transferFrom(_from, _to, _value);
    }
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(crowdSaleEndTime <= block.timestamp);
        return super.approve(_spender, _value);
    }
    function increaseApproval(address _spender, uint _addedValue) public returns (bool success) {
        require(crowdSaleEndTime <= block.timestamp);
        return super.increaseApproval(_spender, _addedValue);
    }
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool success) {
        require(crowdSaleEndTime <= block.timestamp);
        return super.decreaseApproval(_spender, _subtractedValue);
    }
    function increaseLockedBalance(address _address, uint256 _tokens) public onlySales {
        lockedBalancesReleasedAfterOneYear[_address] =
            lockedBalancesReleasedAfterOneYear[_address].add(_tokens);
    }
    function burnInvestorTokens(
        address _address,
        uint256 _amount
    ) public onlyCrowdSale returns (uint256) {
        require(block.timestamp > crowdSaleEndTime);
        require(_amount <= balances[_address]);
        balances[_address] = balances[_address].sub(_amount);
        totalSupply_ = totalSupply_.sub(_amount);
        Transfer(_address, address(0), _amount);
        return _amount;
    }
    function burnUnsoldTokens(uint256 _amount) public onlyCrowdSale {
        require(block.timestamp > crowdSaleEndTime);
        maxSupply = maxSupply.sub(_amount);
        MaxSupplyBurned(_amount);
    }
}
