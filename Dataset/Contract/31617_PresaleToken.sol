contract PresaleToken is Presale {
    string  public standard    = 'Token 0.1';
    string  public name        = 'OpenLongevity';
    string  public symbol      = "YEAR";
    uint8   public decimals    = 0;
    mapping (address => mapping (address => uint)) public allowed;
    modifier onlyPayloadSize(uint size) {
        require(msg.data.length >= size + 4);
        _;
    }
    function PresaleToken() payable public Presale() {}
    function balanceOf(address _who) constant public returns (uint) {
        return investors[_who].amountTokens;
    }
    function transfer(address _to, uint256 _value) public onlyPayloadSize(2 * 32) {
        require(investors[msg.sender].amountTokens >= _value);
        require(investors[_to].amountTokens + _value >= investors[_to].amountTokens);
        investors[msg.sender].amountTokens -= _value;
        if(investors[_to].amountTokens == 0 && investors[_to].amountWei == 0) {
            investorsIter[numberOfInvestors++] = _to;
        }
        investors[_to].amountTokens += _value;
        Transfer(msg.sender, _to, _value);
    }
    function transferFrom(address _from, address _to, uint _value) public onlyPayloadSize(3 * 32) {
        require(investors[_from].amountTokens >= _value);
        require(investors[_to].amountTokens + _value >= investors[_to].amountTokens);  
        require(allowed[_from][msg.sender] >= _value);
        investors[_from].amountTokens -= _value;
        if(investors[_to].amountTokens == 0 && investors[_to].amountWei == 0) {
            investorsIter[numberOfInvestors++] = _to;
        }
        investors[_to].amountTokens += _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
    }
    function approve(address _spender, uint _value) public {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
    }
    function allowance(address _owner, address _spender) public constant
        returns (uint remaining) {
        return allowed[_owner][_spender];
    }
}
