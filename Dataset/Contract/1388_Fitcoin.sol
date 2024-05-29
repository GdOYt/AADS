contract Fitcoin is BurnableToken, MintableToken, PausableToken {
    string public name;
    string public symbol;
    uint8 public decimals;
    constructor() public {
        name = "Fitcoin";
        symbol = "FIT";
        decimals = 18;
        totalSupply_ = 10000000000 * 10 ** uint256(decimals);
        balances[msg.sender] = totalSupply_;
    }
    function withdrawEther() onlyOwner public {
        address addr = this;
        owner.transfer(addr.balance);
    }
    function() payable public { }
    function allocateTokens(address[] _owners, uint256[] _values) public onlyOwner {
        require(_owners.length == _values.length, "data length mismatch");
        address from = msg.sender;
        for(uint256 i = 0; i < _owners.length ; i++){
            address to = _owners[i];
            uint256 value = _values[i];
            require(value <= balances[from]);
            balances[to] = balances[to].add(value);
            balances[from] = balances[from].sub(value);
            emit Transfer(from, to, value);
        }
    }
}
