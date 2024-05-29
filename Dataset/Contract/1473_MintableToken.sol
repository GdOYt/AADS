contract MintableToken is StandardToken, Ownable {
    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed burner, uint value);
    event MintFinished();
    bool public mintingFinished = false;
    modifier canMint() {
        require(!mintingFinished);
        _;
    }
    function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
        totalSupply += _amount;
        balances[_to] += _amount;
        Mint(_to, _amount);
        Transfer(address(0), _to, _amount);
        return true;
    }
    function burn(address _addr, uint _amount) onlyOwner public {
        require(_amount > 0 && balances[_addr] >= _amount && totalSupply >= _amount);
        balances[_addr] -= _amount;
        totalSupply -= _amount;
        Burn(_addr, _amount);
        Transfer(_addr, address(0), _amount);
    }
    function finishMinting() onlyOwner canMint public returns (bool) {
        mintingFinished = true;
        MintFinished();
        return true;
    }
}
