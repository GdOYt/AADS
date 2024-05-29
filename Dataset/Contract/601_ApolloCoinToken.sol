contract ApolloCoinToken is StandardToken, Ownable {
    string  public  constant name = "ApolloCoin";
    string  public  constant symbol = "APC";
    uint8   public  constant decimals = 18;
    uint    public  transferableStartTime;
    address public  tokenSaleContract;
    address public  earlyInvestorWallet;
    modifier onlyWhenTransferEnabled() {
        if ( now <= transferableStartTime ) {
            require(msg.sender == tokenSaleContract || msg.sender == earlyInvestorWallet || msg.sender == owner);
        }
        _;
    }
    modifier validDestination(address to) {
        require(to != address(this));
        _;
    }
    function ApolloCoinToken(uint tokenTotalAmount, uint _transferableStartTime, address _admin, address _earlyInvestorWallet) {
       totalSupply = tokenTotalAmount * (10 ** uint256(decimals));
        balances[msg.sender] = totalSupply;
        Transfer(address(0x0), msg.sender, totalSupply);
        transferableStartTime = _transferableStartTime;      
        tokenSaleContract = msg.sender;
        earlyInvestorWallet = _earlyInvestorWallet;
        transferOwnership(_admin); 
    }
    function transfer(address _to, uint _value) public validDestination(_to) onlyWhenTransferEnabled returns (bool) {
        return super.transfer(_to, _value);
    }
    function transferFrom(address _from, address _to, uint _value) public validDestination(_to) onlyWhenTransferEnabled returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }
    event Burn(address indexed _burner, uint _value);
    function burn(uint _value) public onlyWhenTransferEnabled returns (bool) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(msg.sender, _value);
        Transfer(msg.sender, address(0x0), _value);
        return true;
    }
    function burnFrom(address _from, uint256 _value) public onlyWhenTransferEnabled returns(bool) {
        assert(transferFrom(_from, msg.sender, _value));
        return burn(_value);
    }
    function emergencyERC20Drain(ERC20 token, uint amount ) public onlyOwner {
        token.transfer(owner, amount);
    }
}
