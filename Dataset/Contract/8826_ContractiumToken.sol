contract ContractiumToken is TokenOffering, WithdrawTrack, ContractSpendToken {
    string public constant name = "Contractium";
    string public constant symbol = "CTU";
    uint8 public constant decimals = 18;
    uint256 public constant INITIAL_SUPPLY = 3000000000 * (10 ** uint256(decimals));
    uint256 public unitsOneEthCanBuy = 15000;
    uint256 internal totalWeiRaised;
    event BuyToken(address from, uint256 weiAmount, uint256 tokenAmount);
    function ContractiumToken() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);
    }
    function() public payable {
        require(msg.sender != owner);
        uint256 amount = msg.value.mul(unitsOneEthCanBuy);
        uint256 amountBonus = msg.value.mul(bonusRateOneEth);
        amount = amount.add(amountBonus);
        preValidatePurchase(amount);
        require(balances[owner] >= amount);
        totalWeiRaised = totalWeiRaised.add(msg.value);
        currentTokenOfferingRaised = currentTokenOfferingRaised.add(amount); 
        balances[owner] = balances[owner].sub(amount);
        balances[msg.sender] = balances[msg.sender].add(amount);
        emit Transfer(owner, msg.sender, amount);
        emit BuyToken(msg.sender, msg.value, amount);
        owner.transfer(msg.value);  
    }
    function batchTransfer(address[] _receivers, uint256[] _amounts) public returns(bool) {
        uint256 cnt = _receivers.length;
        require(cnt > 0 && cnt <= 20);
        require(cnt == _amounts.length);
        cnt = (uint8)(cnt);
        uint256 totalAmount = 0;
        for (uint8 i = 0; i < cnt; i++) {
            totalAmount = totalAmount.add(_amounts[i]);
        }
        require(totalAmount <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(totalAmount);
        for (i = 0; i < cnt; i++) {
            balances[_receivers[i]] = balances[_receivers[i]].add(_amounts[i]);            
            emit Transfer(msg.sender, _receivers[i], _amounts[i]);
        }
        return true;
    }
}
