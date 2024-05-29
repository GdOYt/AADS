contract BifreeToken is Ownable, StandardToken {
    string public name = 'Bifree.io Official Token';
    string public symbol = 'BFT';
    uint8 public decimals = 18;
    uint public INITIAL_SUPPLY = 500000000;
    event Burn(address indexed burner, uint256 value);
    event EnableTransfer();
    event DisableTransfer();
    bool public transferable = false;
    modifier whenTransferable() {
        require(transferable || msg.sender == owner);
        _;
    }
    modifier whenNotTransferable() {
        require(!transferable);
        _;
    }
    function BifreeToken() public {
        totalSupply_ = INITIAL_SUPPLY * 10 ** uint256(decimals);
        balances[msg.sender] = totalSupply_;
    }
    function burn(uint256 _value) public {
        require(_value <= balances[msg.sender]);
        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        Burn(burner, _value);
    }
    function enableTransfer() onlyOwner  public {
        transferable = true;
        EnableTransfer();
    }
    function disableTransfer() onlyOwner public
    {
        transferable = false;
        DisableTransfer();
    }
    function transfer(address _to, uint256 _value) public whenTransferable returns (bool) {
        return super.transfer(_to, _value);
    }
    function transferFrom(address _from, address _to, uint256 _value) public whenTransferable returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }
    function approve(address _spender, uint256 _value) public whenTransferable returns (bool) {
        return super.approve(_spender, _value);
    }
    function increaseApproval(address _spender, uint _addedValue) public whenTransferable returns (bool success) {
        return super.increaseApproval(_spender, _addedValue);
    }
    function decreaseApproval(address _spender, uint _subtractedValue) public whenTransferable returns (bool success) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }
}
