contract GSToken is PausableToken {
    string  public name = "GrEARN's Token";
    string  public symbol = "GST";
    uint    public decimals = 18;
    mapping (address => bool) public frozenAccount;
    mapping (address => uint256) public frozenAccountTokens;
    event FrozenFunds(address target, bool frozen);
    event Burn(address indexed burner, uint256 value);
    event Freeze(address indexed from, uint256 value);
    event Unfreeze(address indexed from, uint256 value);
    constructor() public
    {
        totalSupply_ = 60 * 10 ** (uint256(decimals) + 8);
        balances[msg.sender] = totalSupply_;
    }
    function burn(uint256 _value) public onlyOwner returns (bool success) {
        require(balances[msg.sender] >= _value);
        require(_value > 0);
        balances[msg.sender] = SafeMath.sub(balances[msg.sender], _value);   
        totalSupply_ = SafeMath.sub(totalSupply_,_value);
        emit Burn(msg.sender, _value);
        return true;
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(!frozenAccount[_from]);
        require(SafeMath.add(frozenAccountTokens[_from], _value) <= balances[_from]);
        return super.transferFrom(_from, _to, _value);
    }
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(!frozenAccount[msg.sender]);
        require(SafeMath.add(frozenAccountTokens[msg.sender], _value) <= balances[msg.sender]);
        return super.transfer(_to, _value);
    }
    function transferAndFreezeTokens(address _to, uint256 _value) public onlyOwner returns (bool) {
        transfer(_to, _value);
        freezeAccountWithToken(_to, _value);
        return true;
    }
    function freezeAccount(address target, bool freeze) public onlyOwner {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }
    function freezeAccountWithToken(address wallet, uint256 _value) public onlyOwner returns (bool success) {
        require(balances[wallet] >= _value);
        require(_value > 0); 
        frozenAccountTokens[wallet] = SafeMath.add(frozenAccountTokens[wallet], _value);
        emit Freeze(wallet, _value);
        return true;
    }
    function unfreezeAccountWithToken(address wallet, uint256 _value) public onlyOwner returns (bool success) {
        require(balances[wallet] >= _value);
        require(_value > 0); 
        frozenAccountTokens[wallet] = SafeMath.sub(frozenAccountTokens[wallet], _value);         
        emit Unfreeze(wallet, _value);
        return true;
    }
    function multisend(address[] dests, uint256[] values) public onlyOwner returns (uint256) {
        uint256 i = 0;
        while (i < dests.length) {
            transferAndFreezeTokens(dests[i], values[i] * 10 ** 18);
            i += 1;
        }
        return(i);
    }
}
