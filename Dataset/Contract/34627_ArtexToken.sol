contract ArtexToken is MigratableToken {
    string public constant symbol = "ARX";
    string public constant name = "Artex Token";
    mapping(address => bool) public allowedContracts;
    function ArtexToken() payable MigratableToken() {}
    function emitTokens(address _investor, uint _valueUSDWEI) internal returns(uint tokensToEmit) {
        tokensToEmit = getTokensToEmit(_valueUSDWEI);
        require(balances[_investor] + tokensToEmit > balances[_investor]);  
        require(tokensToEmit > 0);
        balances[_investor] += tokensToEmit;
        totalSupply += tokensToEmit;
        Transfer(this, _investor, tokensToEmit);
    }
    function getTokensToEmit(uint _valueUSDWEI) internal constant returns (uint) {
        uint percentWithBonus;
        if (state == State.PreSale) {
            percentWithBonus = 130;
        } else if (state == State.Sale) {
            if (_valueUSDWEI < 1000 * 1 ether)
                percentWithBonus = 100;
            else if (_valueUSDWEI < 5000 * 1 ether)
                percentWithBonus = 103;
            else if (_valueUSDWEI < 10000 * 1 ether)
                percentWithBonus = 105;
            else if (_valueUSDWEI < 50000 * 1 ether)
                percentWithBonus = 110;
            else if (_valueUSDWEI < 100000 * 1 ether)
                percentWithBonus = 115;
            else
                percentWithBonus = 120;
        }
        return (_valueUSDWEI * percentWithBonus * (10 ** uint(decimals))) / (tokenPriceUSDWEI * 100);
    }
    function emitAdditionalTokens() internal {
        uint tokensToEmit = totalSupply * 100 / 74 - totalSupply;
        require(balances[beneficiary] + tokensToEmit > balances[beneficiary]);  
        require(tokensToEmit > 0);
        balances[beneficiary] += tokensToEmit;
        totalSupply += tokensToEmit;
        Transfer(this, beneficiary, tokensToEmit);
    }
    function burnTokens(address _address, uint _amount) internal {
        balances[_address] -= _amount;
        totalSupply -= _amount;
        Transfer(_address, this, _amount);
    }
    function addAllowedContract(address _address) external onlyOwner {
        require(_address != 0);
        allowedContracts[_address] = true;
    }
    function removeAllowedContract(address _address) external onlyOwner {
        require(_address != 0);
        delete allowedContracts[_address];
    }
    function transferToKnownContract(address _to, uint256 _value, bytes32[] _data) external onlyAllowedContracts(_to) {
        var knownContract = KnownContract(_to);
        transfer(_to, _value);
        knownContract.transfered(msg.sender, _value, _data);
    }
    modifier onlyAllowedContracts(address _address) {
        require(allowedContracts[_address] == true);
        _;
    }
}
