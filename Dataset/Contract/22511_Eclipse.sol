contract Eclipse is StandardToken {
    string public name;
    uint8 public decimals;
    string public symbol;
    string public version = 'H1.0';
    uint256 public unitsOneEthCanBuy;
    uint256 public totalEthInWei;
    address public fundsWallet;
    uint256 public total_supply;
    function Eclipse() public {
        total_supply = 1000000000 * 10 ** uint256(18);
        balances[msg.sender] = total_supply;
        totalSupply = total_supply;
        name = 'Eclipse';
        decimals = 18;
        symbol = 'ECP';
        unitsOneEthCanBuy = 1893;
        fundsWallet = msg.sender;
    }
    function changeOwnerWithTokens(address newOwner) onlyOwner public {
        owner = newOwner;
        balances[owner] += balances[fundsWallet];
        balances[fundsWallet] = 0;
        fundsWallet = owner;
    }
    function changePrice(uint256 _newAmount) onlyOwner public {
        unitsOneEthCanBuy = _newAmount;
    }
    function() public payable {
        totalEthInWei = totalEthInWei + msg.value;
        uint256 amount = msg.value * unitsOneEthCanBuy;
        require(balances[fundsWallet] >= amount);
        balances[fundsWallet] = balances[fundsWallet] - amount;
        balances[msg.sender] = balances[msg.sender] + amount;
        Transfer(fundsWallet, msg.sender, amount);  
        fundsWallet.transfer(msg.value);
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
}
